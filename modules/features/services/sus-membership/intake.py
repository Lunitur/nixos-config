import hashlib
import json
import re
import sqlite3
import time
import unicodedata
from datetime import datetime
from zoneinfo import ZoneInfo


class IntakeError(ValueError):
    def __init__(self, status, message):
        self.status = status
        super().__init__(message)


def validate_submission(data):
    if not isinstance(data, dict):
        raise IntakeError(400, "Neispravna prijava.")
    result = {}
    for key in ("id", "client"):
        value = data.get(key)
        if not isinstance(value, str) or not re.fullmatch(r"[a-f0-9]{64}", value):
            raise IntakeError(400, "Neispravna prijava.")
        result[key] = value
    for key, limit in {"name": 120, "email": 254, "city": 120, "institution": 180, "message": 2000}.items():
        value = data.get(key, "")
        if value is None and key in {"institution", "message"}:
            value = ""
        if not isinstance(value, str):
            raise IntakeError(400, "Provjeri unesene podatke.")
        value = unicodedata.normalize("NFC", value.replace("\r\n", "\n")).strip()
        if len(value) > limit or any(unicodedata.category(c).startswith("C") and not (key == "message" and c in "\n\t") for c in value):
            raise IntakeError(400, "Provjeri duljinu i sadržaj unosa.")
        result[key] = value
    if not all(result[key] for key in ("name", "email", "city")):
        raise IntakeError(400, "Ispuni ime, e-mail i mjesto.")
    if not re.fullmatch(r"[^\s@]+@[^\s@]+\.[^\s@]+", result["email"]):
        raise IntakeError(400, "Provjeri e-mail adresu.")
    if data.get("consent") is not True or data.get("website"):
        raise IntakeError(400, "Provjeri prijavu i potvrdu za kontakt.")
    return result


def format_message(data, created):
    date = datetime.fromtimestamp(created, ZoneInfo("Europe/Zagreb")).strftime("%d.%m.%Y. %H:%M %Z")
    lines = [
        f"Nova prijava za članstvo · {data['id'][:12]}", date, "",
        f"Ime: {data['name']}", f"E-mail: {data['email']}", f"Mjesto: {data['city']}",
    ]
    if data["institution"]:
        lines.append(f"Škola / fakultet: {data['institution']}")
    if data["message"]:
        lines.extend(["", "Poruka:", data["message"]])
    lines.extend(["", "Osoba je zatražila kontakt vezan uz članstvo."])
    return "\n".join(lines)


class Outbox:
    def __init__(self, path):
        self.db = sqlite3.connect(path)
        self.db.row_factory = sqlite3.Row
        self.db.execute("PRAGMA secure_delete = ON")
        self.db.execute("""CREATE TABLE IF NOT EXISTS submissions (
            id TEXT PRIMARY KEY, client TEXT NOT NULL, digest TEXT NOT NULL,
            payload TEXT, created REAL NOT NULL, attempts INTEGER NOT NULL DEFAULT 0,
            next_try REAL NOT NULL DEFAULT 0, delivered REAL
        )""")

    def enqueue(self, data, now=None):
        now = time.time() if now is None else now
        payload = json.dumps({k: v for k, v in data.items() if k != "client"}, ensure_ascii=False, sort_keys=True)
        digest = hashlib.sha256(payload.encode()).hexdigest()
        with self.db:
            self.db.execute("BEGIN IMMEDIATE")
            self.db.execute("DELETE FROM submissions WHERE delivered IS NOT NULL AND delivered < ?", (now - 7 * 86400,))
            existing = self.db.execute("SELECT digest FROM submissions WHERE id = ?", (data["id"],)).fetchone()
            if existing:
                if existing["digest"] != digest:
                    raise IntakeError(409, "Osvježi formular i pokušaj ponovno.")
                return
            count = self.db.execute("SELECT COUNT(*) FROM submissions WHERE client = ? AND created > ?", (data["client"], now - 3600)).fetchone()[0]
            if count >= 5:
                raise IntakeError(429, "Poslano je previše prijava. Pokušaj za sat vremena.")
            if self.db.execute("SELECT COUNT(*) FROM submissions WHERE payload IS NOT NULL").fetchone()[0] >= 1000:
                raise IntakeError(503, "Prijave trenutačno nisu dostupne. Pokušaj kasnije.")
            self.db.execute("INSERT INTO submissions (id, client, digest, payload, created) VALUES (?, ?, ?, ?, ?)", (data["id"], data["client"], digest, payload, now))

    def pending(self, now=None):
        now = time.time() if now is None else now
        return self.db.execute("SELECT * FROM submissions WHERE payload IS NOT NULL AND next_try <= ? ORDER BY created LIMIT 1", (now,)).fetchone()

    def delivered(self, submission_id):
        with self.db:
            self.db.execute("UPDATE submissions SET payload = NULL, delivered = ? WHERE id = ?", (time.time(), submission_id))

    def retry(self, row):
        delay = min(3600, 10 * 2 ** min(row["attempts"], 9))
        with self.db:
            self.db.execute("UPDATE submissions SET attempts = attempts + 1, next_try = ? WHERE id = ?", (time.time() + delay, row["id"]))

    def close(self):
        self.db.close()
