import asyncio
import hmac
import json
import os
from contextlib import suppress
from pathlib import Path

from aiohttp import web
from maubot import Plugin
from maubot.handlers import web as handlers
from mautrix.errors import MNotFound
from mautrix.types import EventType, MessageType, RoomID, TextMessageEventContent

from intake import IntakeError, Outbox, format_message, validate_submission


class MembershipBot(Plugin):
    async def start(self):
        credentials = Path(os.environ["CREDENTIALS_DIRECTORY"])
        self.secret = (credentials / "webhook-token").read_text().strip()
        self.room = RoomID(json.loads((credentials / "bot.json").read_text())["room_id"])
        self.outbox = Outbox("outbox.sqlite")
        self.require_encryption = os.environ.get("SUS_MEMBERSHIP_REQUIRE_ENCRYPTION") == "1" or Path("encryption-required").exists()
        self.ready = False
        self.wakeup = asyncio.Event()
        self.worker = asyncio.create_task(self.deliver())

    async def stop(self):
        self.worker.cancel()
        with suppress(asyncio.CancelledError):
            await self.worker
        self.outbox.close()

    def authorized(self, request):
        return hmac.compare_digest(request.headers.get("Authorization", ""), f"Bearer {self.secret}")

    @handlers.get("/ready")
    async def health(self, request):
        if not self.authorized(request):
            return web.json_response({}, status=401)
        return web.json_response({"ready": self.ready}, status=200 if self.ready else 503)

    @handlers.post("/submit")
    async def submit(self, request):
        if not self.authorized(request):
            return web.json_response({}, status=401)
        if not self.ready:
            return web.json_response({"message": "Prijave trenutačno nisu dostupne. Pokušaj kasnije."}, status=503)
        try:
            if request.content_length is not None and request.content_length > 16384:
                raise IntakeError(413, "Prijava je prevelika.")
            raw = await request.content.read(16385)
            if len(raw) > 16384:
                raise IntakeError(413, "Prijava je prevelika.")
            data = validate_submission(json.loads(raw))
            self.outbox.enqueue(data)
        except (json.JSONDecodeError, UnicodeDecodeError):
            return web.json_response({"message": "Neispravna prijava."}, status=400)
        except IntakeError as error:
            return web.json_response({"message": str(error)}, status=error.status)
        self.wakeup.set()
        return web.json_response({"accepted": True}, status=202)

    async def check_room(self):
        if self.room not in await self.client.get_joined_rooms():
            await self.client.join_room(self.room)
        rules = await self.client.get_state_event(self.room, EventType.ROOM_JOIN_RULES)
        history = await self.client.get_state_event(self.room, EventType.ROOM_HISTORY_VISIBILITY)
        if rules.join_rule == "public" or history.history_visibility == "world_readable":
            raise RuntimeError("Ciljna soba za prijave mora biti privatna.")
        try:
            encryption = await self.client.get_state_event(self.room, EventType.ROOM_ENCRYPTION)
        except MNotFound:
            if self.require_encryption:
                raise RuntimeError("Ciljna soba mora biti šifrirana.")
            return False
        if encryption.algorithm != "m.megolm.v1.aes-sha2":
            raise RuntimeError("Ciljna soba mora koristiti Megolm enkripciju.")
        self.require_encryption = True
        Path("encryption-required").touch(mode=0o600)
        if not self.client.crypto:
            raise RuntimeError("Šifrirana soba zahtijeva kriptografsku podršku maubota.")
        return True

    async def deliver(self):
        while True:
            row = None
            self.wakeup.clear()
            try:
                if not self.ready:
                    await self.check_room()
                    self.ready = True
                row = self.outbox.pending()
                if row:
                    encrypted_room = await self.check_room()
                    content = TextMessageEventContent(msgtype=MessageType.NOTICE, body=format_message(json.loads(row["payload"]), row["created"]))
                    content["m.mentions"] = {}
                    event_type = EventType.ROOM_MESSAGE
                    if encrypted_room:
                        content = await self.client.encrypt(self.room, event_type, content)
                        event_type = EventType.ROOM_ENCRYPTED
                    await self.client.send_message_event(self.room, event_type, content, txn_id=f"sus-{row['id']}")
                    self.outbox.delivered(row["id"])
                    continue
            except Exception as error:
                if row:
                    self.outbox.retry(row)
                reason = str(error) if type(error) is RuntimeError else type(error).__name__
                self.log.warning("Dostava prijave čeka ponovni pokušaj (%s).", reason)
            with suppress(TimeoutError):
                await asyncio.wait_for(self.wakeup.wait(), timeout=10)
