import email.policy
import hashlib
import json
import logging
import os
import sqlite3
import time
from email.parser import BytesParser
from html.parser import HTMLParser
from pathlib import Path

from matrix import Matrix, MatrixError, quote

MAX_TEXT = 12000
MAX_EMAIL = 32 * 1024 * 1024
log = logging.getLogger("sus-mail")


class PlainHTML(HTMLParser):
    def __init__(self):
        super().__init__(convert_charrefs=True)
        self.parts = []
        self.hidden = 0

    def handle_starttag(self, tag, attrs):
        if tag in {"script", "style"}:
            self.hidden += 1
        if tag in {"br", "p", "div", "li", "tr"} and not self.hidden:
            self.parts.append("\n")

    def handle_endtag(self, tag):
        if tag in {"script", "style"}:
            self.hidden = max(0, self.hidden - 1)
        if tag in {"p", "div", "li", "tr"} and not self.hidden:
            self.parts.append("\n")

    def handle_data(self, data):
        if not self.hidden:
            self.parts.append(data)


def format_mail(raw):
    message = BytesParser(policy=email.policy.default).parsebytes(raw)
    part = message.get_body(preferencelist=("plain", "html"))
    body = ""
    if part:
        try:
            body = part.get_content()
        except (LookupError, UnicodeError):
            body = part.get_payload(decode=True).decode("utf-8", errors="replace")
        if part.get_content_type() == "text/html":
            parser = PlainHTML()
            parser.feed(body)
            body = "".join(parser.parts)
    attachments = list(message.iter_attachments())
    original = bool(attachments) or len(body) > MAX_TEXT or not body.strip()
    headers = "\n".join(f"{label}: {message.get(label, '(none)')}" for label in ("From", "To", "Subject", "Date"))
    text = f"{headers}\n\n{body.strip() or '(No readable text body.)'}"
    if len(text) > MAX_TEXT:
        text = text[:MAX_TEXT] + "\n[Continued in the original email.]"
        original = True
    if attachments:
        text += f"\n\n[{len(attachments)} attachment(s); included in the original email.]"
    return text, original


def inbox_files(maildir):
    files = {}
    for name in ("new", "cur"):
        with os.scandir(maildir / name) as entries:
            for entry in entries:
                if entry.is_file(follow_symlinks=False):
                    files[entry.name.split(":2,", 1)[0]] = Path(entry.path)
    return files


class Outbox:
    def __init__(self, path, source, room, user):
        self.db = sqlite3.connect(path)
        self.db.row_factory = sqlite3.Row
        self.db.execute("PRAGMA secure_delete = ON")
        self.db.executescript("""
            CREATE TABLE IF NOT EXISTS metadata (key TEXT PRIMARY KEY, value TEXT NOT NULL);
            CREATE TABLE IF NOT EXISTS messages (
                key TEXT PRIMARY KEY, payload BLOB, media TEXT,
                attempts INTEGER NOT NULL DEFAULT 0, retry_at REAL NOT NULL DEFAULT 0
            );
        """)
        binding = json.dumps([source, room, user])
        existing = self.db.execute("SELECT value FROM metadata WHERE key = 'binding'").fetchone()
        if existing and existing[0] != binding:
            self.db.close()
            raise RuntimeError("Mailbox or Matrix identity changed; use a separate delivery database.")
        with self.db:
            self.db.execute("INSERT OR IGNORE INTO metadata VALUES ('binding', ?)", (binding,))

    def scan(self, maildir):
        files = inbox_files(maildir)
        if not self.db.execute("SELECT 1 FROM metadata WHERE key = 'initialized'").fetchone():
            # The first snapshot is a baseline, including already-read messages in cur/.
            with self.db:
                self.db.executemany("INSERT OR IGNORE INTO messages (key) VALUES (?)", ((key,) for key in files))
                self.db.execute("INSERT INTO metadata VALUES ('initialized', '1')")
            log.info("Initialized inbox baseline; existing messages will not be forwarded.")
            return
        for key, path in files.items():
            if self.db.execute("SELECT 1 FROM messages WHERE key = ?", (key,)).fetchone():
                continue
            try:
                with path.open("rb") as stream:
                    raw = stream.read(MAX_EMAIL + 1)
            except FileNotFoundError:
                continue
            if len(raw) > MAX_EMAIL:
                log.warning("An inbox message exceeds the forwarding size limit; leaving it for retry.")
                continue
            with self.db:
                self.db.execute("INSERT OR IGNORE INTO messages (key, payload) VALUES (?, ?)", (key, raw))

    def deliver(self, client, room, now=None):
        now = time.time() if now is None else now
        rows = self.db.execute("SELECT * FROM messages WHERE payload IS NOT NULL AND retry_at <= ? ORDER BY rowid LIMIT 20", (now,)).fetchall()
        for row in rows:
            try:
                text, original = format_mail(row["payload"])
                transaction = "mail-" + hashlib.sha256(row["key"].encode()).hexdigest()
                client.send(room, transaction + "-text", {"msgtype": "m.notice", "body": text, "m.mentions": {}})
                if original:
                    media = row["media"]
                    if not media:
                        client.check_room(room)
                        media = client.upload(row["payload"])
                        with self.db:
                            self.db.execute("UPDATE messages SET media = ? WHERE key = ?", (media, row["key"]))
                    client.send(room, transaction + "-original", {
                        "msgtype": "m.file", "body": "message.eml", "filename": "message.eml", "url": media,
                        "info": {"mimetype": "message/rfc822", "size": len(row["payload"])}, "m.mentions": {},
                    })
                with self.db:
                    self.db.execute("UPDATE messages SET payload = NULL, media = NULL WHERE key = ?", (row["key"],))
                log.info("Forwarded one email to the configured Matrix room.")
            except Exception as error:
                with self.db:
                    self.db.execute("UPDATE messages SET attempts = attempts + 1, retry_at = ? WHERE key = ?", (now + min(3600, 15 * 2 ** min(row["attempts"], 8)), row["key"]))
                reason = str(error) if isinstance(error, MatrixError) or type(error) is RuntimeError else type(error).__name__
                log.warning("Email delivery will retry (%s).", reason)


def main():
    logging.basicConfig(level=logging.INFO, format="%(levelname)s: %(message)s")
    credentials = Path(os.environ["CREDENTIALS_DIRECTORY"], "bot.json")
    identity = json.loads(credentials.read_text())
    room = identity["room_id"]
    client = Matrix(identity["homeserver"], identity["access_token"])
    outbox = Outbox("outbox.sqlite", os.environ["SUS_MAIL_SOURCE"], room, identity["user_id"])
    interval = int(os.environ.get("SUS_MAIL_POLL_INTERVAL", "15"))
    joined = False
    while True:
        try:
            outbox.scan(Path("/mailbox"))
            if not joined:
                client.api("POST", "/join/" + quote(room), {})
                client.check_room(room)
                joined = True
                log.info("Connected to the configured Matrix room.")
            outbox.deliver(client, room)
        except Exception as error:
            reason = str(error) if isinstance(error, MatrixError) or type(error) is RuntimeError else type(error).__name__
            log.warning("Mail forwarding is waiting to retry (%s).", reason)
        time.sleep(interval)


if __name__ == "__main__":
    main()
