import asyncio
import contextlib
import io
import json
import logging
import os
import tempfile
import time
import unittest
from pathlib import Path
from unittest.mock import AsyncMock, Mock, patch

from aiohttp import web
from aiohttp.test_utils import TestClient, TestServer
from mautrix.errors import MNotFound
from mautrix.types import EventType, RoomID

from intake import IntakeError, Outbox, validate_submission
from membership import MembershipBot
import setup


def submission(number=1, **overrides):
    return {"id": f"{number:064x}", "client": "a" * 64, "name": "Test prijava", "email": "test@example.invalid", "city": "Zagreb", "institution": "", "message": "", "consent": True, **overrides}


class SetupTests(unittest.TestCase):
    def test_alias_resolution_preserves_identity_for_modern_and_legacy_room_ids(self):
        for room_id in ("!" + "a" * 43, "!legacy:example.invalid"):
            with self.subTest(room_id=room_id), tempfile.TemporaryDirectory() as temporary:
                directory = Path(temporary)
                identity = {"credentials": {
                    "id": "@sus-test:example.invalid", "homeserver": "https://example.invalid",
                    "access_token": "test-token", "device_id": "TEST",
                }, "pickle_key": "test-key"}
                (directory / "bot.json").write_text(json.dumps(identity))
                with (
                    patch.object(setup, "Path", return_value=directory),
                    patch.dict(os.environ, {"SUS_MEMBERSHIP_ROOM": "#prijave:example.invalid"}),
                    patch("sys.argv", ["sus-membership-setup"]),
                    patch.object(setup.os, "geteuid", return_value=0),
                    patch.object(setup.os, "umask"),
                    patch.object(setup, "api", side_effect=[(200, {"room_id": room_id}), (403, {"errcode": "M_FORBIDDEN"})]) as api,
                    patch.object(setup.subprocess, "run") as restart,
                    contextlib.redirect_stdout(io.StringIO()) as output,
                ):
                    setup.main()
                saved = json.loads((directory / "bot.json").read_text())
                self.assertEqual(saved, {**identity, "room_id": room_id})
                self.assertEqual(api.call_count, 2)
                self.assertTrue(api.call_args.args[2].startswith("/join/%21"))
                restart.assert_called_once_with(["systemctl", "restart", "sus-membership.service"], check=True)
                self.assertIn("Pozovi @sus-test:example.invalid", output.getvalue())
                self.assertNotIn("test-token", output.getvalue())


class OutboxTests(unittest.TestCase):
    def setUp(self):
        self.directory = tempfile.TemporaryDirectory()
        self.path = Path(self.directory.name, "outbox.sqlite")
        self.outbox = Outbox(self.path)

    def tearDown(self):
        self.outbox.close()
        self.directory.cleanup()

    def test_durable_retry_idempotency_and_erasure(self):
        data = validate_submission(submission(message="Privatna poruka"))
        self.outbox.enqueue(data)
        self.outbox.enqueue(data)
        self.outbox.close()
        self.outbox = Outbox(self.path)
        row = self.outbox.pending()
        self.assertEqual(json.loads(row["payload"])["message"], "Privatna poruka")
        self.outbox.retry(row)
        self.assertIsNone(self.outbox.pending())
        self.assertEqual(self.outbox.pending(time.time() + 20)["attempts"], 1)
        self.outbox.delivered(data["id"])
        self.assertIsNone(self.outbox.pending())
        self.assertNotIn(b"Privatna poruka", self.path.read_bytes())
        self.outbox.enqueue(data)
        self.assertIsNone(self.outbox.pending())

    def test_changed_duplicate_is_rejected(self):
        self.outbox.enqueue(validate_submission(submission()))
        with self.assertRaises(IntakeError) as error:
            self.outbox.enqueue(validate_submission(submission(city="Rijeka")))
        self.assertEqual(error.exception.status, 409)

    def test_rate_limit_and_recovery(self):
        for number in range(5):
            self.outbox.enqueue(validate_submission(submission(number)), now=1000)
        with self.assertRaises(IntakeError) as error:
            self.outbox.enqueue(validate_submission(submission(6)), now=1001)
        self.assertEqual(error.exception.status, 429)
        self.outbox.enqueue(validate_submission(submission(6)), now=4601)

    def test_invalid_values_never_enter_queue(self):
        for overrides in ({"consent": False}, {"website": "spam"}, {"email": "invalid"}, {"name": ["name"]}, {"name": "Ime\nLažni redak"}, {"message": "x" * 2001}, {"id": "invalid"}):
            with self.subTest(overrides=overrides), self.assertRaises(IntakeError):
                validate_submission(submission(**overrides))

    def test_grav_optional_empty_fields(self):
        data = validate_submission(submission(institution=None, message=None))
        self.assertEqual((data["institution"], data["message"]), ("", ""))


class BotTests(unittest.IsolatedAsyncioTestCase):
    async def asyncSetUp(self):
        self.directory = tempfile.TemporaryDirectory()
        self.original = Path.cwd()
        os.chdir(self.directory.name)
        self.bot = object.__new__(MembershipBot)
        self.bot.secret = "test-secret"
        self.bot.room = RoomID("!test:example.invalid")
        self.bot.require_encryption = False
        self.bot.ready = True
        self.bot.outbox = Outbox("outbox.sqlite")
        self.bot.wakeup = asyncio.Event()
        self.bot.log = logging.getLogger("test")
        self.bot.client = Mock()
        self.bot.client.get_joined_rooms = AsyncMock(return_value=[self.bot.room])
        self.encrypted = False
        self.public = False
        async def get_state(room, event_type):
            if event_type == EventType.ROOM_JOIN_RULES:
                return Mock(join_rule="public" if self.public else "invite")
            if event_type == EventType.ROOM_HISTORY_VISIBILITY:
                return Mock(history_visibility="joined")
            if self.encrypted:
                return Mock(algorithm="m.megolm.v1.aes-sha2")
            raise MNotFound("M_NOT_FOUND", "Not encrypted")
        self.bot.client.get_state_event = AsyncMock(side_effect=get_state)
        self.bot.client.encrypt = AsyncMock(return_value={"ciphertext": "test-ciphertext"})
        self.bot.client.send_message_event = AsyncMock(return_value="$test")
        app = web.Application()
        app.router.add_get("/ready", self.bot.health)
        app.router.add_post("/submit", self.bot.submit)
        self.http = TestClient(TestServer(app))
        await self.http.start_server()

    async def asyncTearDown(self):
        await self.http.close()
        self.bot.outbox.close()
        os.chdir(self.original)
        self.directory.cleanup()

    async def post(self, data, secret="test-secret"):
        return await self.http.post("/submit", json=data, headers={"Authorization": f"Bearer {secret}"})

    async def run_worker(self):
        worker = asyncio.create_task(self.bot.deliver())
        try:
            for _ in range(100):
                if self.bot.outbox.pending() is None:
                    return
                await asyncio.sleep(0.01)
            self.fail("Worker nije obradio prijavu.")
        finally:
            worker.cancel()
            with self.assertRaises(asyncio.CancelledError):
                await worker

    async def test_authenticated_intake_and_duplicate(self):
        self.assertEqual((await self.post(submission(), secret="wrong")).status, 401)
        self.assertEqual((await self.post(submission(consent=False))).status, 400)
        self.assertEqual((await self.post(submission())).status, 202)
        self.assertEqual((await self.post(submission())).status, 202)
        await self.run_worker()
        self.bot.client.send_message_event.assert_awaited_once()
        args, kwargs = self.bot.client.send_message_event.call_args
        self.assertEqual(args[1], EventType.ROOM_MESSAGE)
        self.assertEqual(args[2]["m.mentions"], {})
        self.assertEqual(kwargs["txn_id"], "sus-" + submission()["id"])

    async def test_size_limit_and_not_ready(self):
        self.assertEqual((await self.post(submission(message="x" * 17000))).status, 413)
        self.bot.ready = False
        self.assertEqual((await self.post(submission())).status, 503)
        response = await self.http.get("/ready", headers={"Authorization": "Bearer test-secret"})
        self.assertEqual(response.status, 503)

    async def test_encrypted_room_encrypts_before_send_and_disallows_downgrade(self):
        self.encrypted = True
        await self.post(submission())
        await self.run_worker()
        self.bot.client.encrypt.assert_awaited_once()
        self.assertEqual(self.bot.client.send_message_event.call_args.args[1], EventType.ROOM_ENCRYPTED)
        self.assertTrue(Path("encryption-required").exists())
        self.encrypted = False
        with self.assertRaises(RuntimeError):
            await self.bot.check_room()

    async def test_public_room_and_missing_crypto_never_receive_private_data(self):
        self.public = True
        with self.assertRaises(RuntimeError):
            await self.bot.check_room()
        self.public = False
        self.encrypted = True
        self.bot.client.crypto = None
        with self.assertRaises(RuntimeError):
            await self.bot.check_room()
        self.bot.client.send_message_event.assert_not_awaited()

    async def test_send_failure_preserves_private_payload_for_retry(self):
        self.bot.client.send_message_event.side_effect = TimeoutError()
        await self.post(submission())
        await self.run_worker()
        row = self.bot.outbox.pending(time.time() + 100)
        self.assertIsNotNone(row["payload"])
        self.assertEqual(row["attempts"], 1)
        self.assertIsNone(row["delivered"])


if __name__ == "__main__":
    unittest.main()
