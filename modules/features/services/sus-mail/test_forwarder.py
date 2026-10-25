import io
import json
import tempfile
import unittest
import urllib.error
from email.message import EmailMessage
from pathlib import Path
from unittest.mock import Mock, patch

from forwarder import MAX_TEXT, Outbox, format_mail
from matrix import Matrix, MatrixError
from setup import register


def mail(body="Hello from the test inbox.", attachment=False, html=False):
    message = EmailMessage()
    message["From"] = "sender@example.invalid"
    message["To"] = "kontakt@sus.autonomija.net"
    message["Subject"] = "Test čćžšđ"
    message.set_content(body, subtype="html" if html else "plain")
    if attachment:
        message.add_attachment(b"test attachment", maintype="application", subtype="octet-stream", filename="test.bin")
    return message.as_bytes()


class FormattingTests(unittest.TestCase):
    def test_plain_email_preserves_unicode_headers_and_body(self):
        text, original = format_mail(mail())
        self.assertIn("Test čćžšđ", text)
        self.assertIn("Hello from the test inbox.", text)
        self.assertFalse(original)

    def test_html_is_converted_without_loading_images_or_scripts(self):
        text, original = format_mail(mail("<p>Hello &amp; welcome.</p><script>hidden</script><img src='https://example.invalid/track'>", html=True))
        self.assertIn("Hello & welcome.", text)
        self.assertNotIn("hidden", text)
        self.assertNotIn("track", text)
        self.assertFalse(original)

    def test_attachments_and_long_mail_include_original(self):
        self.assertTrue(format_mail(mail(attachment=True))[1])
        text, original = format_mail(mail("x" * (MAX_TEXT + 100)))
        self.assertTrue(original)
        self.assertIn("Continued in the original email", text)
        self.assertLess(len(text), MAX_TEXT + 100)


class DeliveryTests(unittest.TestCase):
    def setUp(self):
        self.temporary = tempfile.TemporaryDirectory()
        self.directory = Path(self.temporary.name)
        self.maildir = self.directory / "mail"
        for folder in ("new", "cur", "tmp"):
            (self.maildir / folder).mkdir(parents=True)
        self.database = self.directory / "outbox.sqlite"
        self.outbox = self.open_outbox()
        self.client = Mock()

    def tearDown(self):
        self.outbox.db.close()
        self.temporary.cleanup()

    def open_outbox(self):
        return Outbox(self.database, "sus-inbox", "!room", "@sus-mail:example.invalid")

    def test_baseline_skips_existing_read_and_unread_mail(self):
        (self.maildir / "new/old-unread").write_bytes(mail())
        (self.maildir / "cur/old-read:2,S").write_bytes(mail())
        self.outbox.scan(self.maildir)
        self.outbox.deliver(self.client, "!room")
        self.client.send.assert_not_called()
        (self.maildir / "new/fresh").write_bytes(mail())
        self.outbox.scan(self.maildir)
        self.outbox.deliver(self.client, "!room")
        self.assertEqual(self.client.send.call_count, 1)
        self.assertTrue((self.maildir / "new/fresh").exists())
        content = self.client.send.call_args.args[2]
        self.assertEqual(content["m.mentions"], {})
        self.assertEqual(content["msgtype"], "m.notice")

    def test_read_flags_and_restart_do_not_duplicate_mail(self):
        self.outbox.scan(self.maildir)
        path = self.maildir / "new/fresh"
        path.write_bytes(mail())
        self.outbox.scan(self.maildir)
        self.outbox.deliver(self.client, "!room")
        path.rename(self.maildir / "cur/fresh:2,S")
        self.outbox.db.close()
        self.outbox = self.open_outbox()
        self.outbox.scan(self.maildir)
        self.outbox.deliver(self.client, "!room")
        self.assertEqual(self.client.send.call_count, 1)

    def test_retry_survives_deleted_source_and_reuses_transactions_and_upload(self):
        self.outbox.scan(self.maildir)
        path = self.maildir / "new/fresh"
        raw = mail("Private body to remove from the spool.", attachment=True)
        path.write_bytes(raw)
        self.outbox.scan(self.maildir)
        self.client.upload.return_value = "mxc://example.invalid/file"
        self.client.send.side_effect = [None, OSError("temporary failure")]
        self.outbox.deliver(self.client, "!room", now=100)
        initial_transactions = [call.args[1] for call in self.client.send.call_args_list]
        path.unlink()
        self.outbox.db.close()
        self.outbox = self.open_outbox()
        self.client.send.side_effect = None
        self.outbox.deliver(self.client, "!room", now=110)
        self.assertEqual(self.client.send.call_count, 2)
        self.outbox.deliver(self.client, "!room", now=120)
        self.assertEqual(initial_transactions, [call.args[1] for call in self.client.send.call_args_list[2:]])
        self.client.upload.assert_called_once_with(raw)
        self.assertIsNone(self.outbox.db.execute("SELECT payload FROM messages WHERE key = 'fresh'").fetchone()[0])
        self.assertNotIn(b"Private body to remove", self.database.read_bytes())

    def test_a_failed_email_does_not_block_later_mail(self):
        self.outbox.scan(self.maildir)
        (self.maildir / "new/first").write_bytes(mail())
        (self.maildir / "new/second").write_bytes(mail())
        self.outbox.scan(self.maildir)
        self.client.send.side_effect = [OSError("failure"), None]
        self.outbox.deliver(self.client, "!room", now=100)
        remaining = self.outbox.db.execute("SELECT count(*) FROM messages WHERE payload IS NOT NULL").fetchone()[0]
        self.assertEqual(remaining, 1)

    def test_changing_destination_is_rejected(self):
        with self.assertRaises(RuntimeError):
            Outbox(self.database, "sus-inbox", "!other-room", "@sus-mail:example.invalid")


class MatrixTests(unittest.TestCase):
    def test_plaintext_is_never_sent_to_an_encrypted_room(self):
        client = Matrix("https://example.invalid", "secret")
        client.api = Mock(return_value={"algorithm": "m.megolm.v1.aes-sha2"})
        with self.assertRaises(RuntimeError):
            client.send("!room", "transaction", {"body": "private email"})
        self.assertEqual(client.api.call_count, 1)

    def test_room_state_failures_do_not_allow_plaintext(self):
        client = Matrix("https://example.invalid")
        client.api = Mock(side_effect=MatrixError(403, "M_FORBIDDEN"))
        with self.assertRaises(MatrixError):
            client.send("!room", "transaction", {"body": "private email"})
        self.assertEqual(client.api.call_count, 1)

    def test_send_uses_bearer_token_encoded_room_and_stable_transaction(self):
        client = Matrix("https://example.invalid", "test-secret")
        missing = urllib.error.HTTPError("https://example.invalid", 404, "Not Found", {}, io.BytesIO(b'{"errcode":"M_NOT_FOUND"}'))
        response = Mock()
        response.__enter__ = Mock(return_value=io.BytesIO(b'{"event_id":"$test"}'))
        response.__exit__ = Mock(return_value=False)
        with patch("urllib.request.urlopen", side_effect=[missing, response]) as request:
            client.send("!room:example.invalid", "mail-123-text", {"body": "test", "msgtype": "m.notice"})
        sent = request.call_args.args[0]
        self.assertEqual(sent.method, "PUT")
        self.assertIn("/rooms/%21room%3Aexample.invalid/send/m.room.message/mail-123-text", sent.full_url)
        self.assertEqual(sent.get_header("Authorization"), "Bearer test-secret")
        self.assertEqual(json.loads(sent.data)["body"], "test")

    def test_registration_completes_token_and_dummy_stages(self):
        client = Mock()
        flow = {"session": "private-session", "flows": [{"stages": ["m.login.registration_token", "m.login.dummy"]}]}
        client.api.side_effect = [
            MatrixError(401, "unknown", flow),
            MatrixError(401, "unknown", {**flow, "completed": ["m.login.registration_token"]}),
            {"user_id": "@sus-mail:example.invalid"},
        ]
        requests = []
        def call(method, path, data):
            requests.append(json.loads(json.dumps(data)))
            result = next(responses)
            if isinstance(result, Exception):
                raise result
            return result
        responses = iter(client.api.side_effect)
        client.api.side_effect = call
        result = register(client, {"username": "sus-mail", "password": "password"}, "registration-secret")
        self.assertEqual(result["user_id"], "@sus-mail:example.invalid")
        self.assertNotIn("auth", requests[0])
        self.assertEqual(requests[1]["auth"]["token"], "registration-secret")
        self.assertEqual(requests[2]["auth"]["type"], "m.login.dummy")


if __name__ == "__main__":
    unittest.main()
