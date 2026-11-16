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
from tables import Tables


class MembershipBot(Plugin):
    async def start(self):
        credentials = Path(os.environ["CREDENTIALS_DIRECTORY"])
        self.secret = (credentials / "webhook-token").read_text().strip()
        self.room = RoomID(json.loads((credentials / "bot.json").read_text())["room_id"])
        self.tables = Tables(json.loads((credentials / "nextcloud.json").read_text())) if os.environ.get("SUS_MEMBERSHIP_TABLES") == "1" else None
        self.outbox = Outbox("outbox.sqlite", tables_enabled=self.tables is not None)
        self.require_encryption = os.environ.get("SUS_MEMBERSHIP_REQUIRE_ENCRYPTION") == "1" or Path("encryption-required").exists()
        self.ready = False
        self.wakeup = asyncio.Event()
        self.worker = asyncio.create_task(self.deliver())

    async def stop(self):
        self.worker.cancel()
        with suppress(asyncio.CancelledError):
            await self.worker
        if self.tables:
            await self.tables.close()
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

    async def deliver_matrix(self, row):
        encrypted_room = await self.check_room()
        content = TextMessageEventContent(msgtype=MessageType.NOTICE, body=format_message(json.loads(row["payload"]), row["created"]))
        content["m.mentions"] = {}
        event_type = EventType.ROOM_MESSAGE
        if encrypted_room:
            content = await self.client.encrypt(self.room, event_type, content)
            event_type = EventType.ROOM_ENCRYPTED
        await self.client.send_message_event(self.room, event_type, content, txn_id=f"sus-{row['id']}")

    async def deliver(self):
        while True:
            self.wakeup.clear()
            progress = False
            for destination in ("matrix", "tables"):
                if destination == "tables" and self.tables is None:
                    continue
                row = None
                try:
                    if destination == "matrix" and not self.ready:
                        await self.check_room()
                        self.ready = True
                    row = self.outbox.pending(destination=destination)
                    if row:
                        if destination == "matrix":
                            await self.deliver_matrix(row)
                        else:
                            await self.tables.deliver(json.loads(row["payload"]), row["created"])
                        self.outbox.delivered(row["id"], destination)
                        progress = True
                except Exception as error:
                    if row:
                        self.outbox.retry(row, destination)
                    reason = str(error) if type(error) is RuntimeError else type(error).__name__
                    self.log.warning("Dostava prijave (%s) čeka ponovni pokušaj (%s).", destination, reason)
            if progress:
                continue
            with suppress(TimeoutError):
                await asyncio.wait_for(self.wakeup.wait(), timeout=10)
