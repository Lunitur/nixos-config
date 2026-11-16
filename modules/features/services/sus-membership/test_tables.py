from base64 import b64decode
import unittest

from aiohttp import web
from aiohttp.test_utils import TestServer

from tables import Tables


DATA = {
    "id": "a" * 64, "name": "Test prijava", "email": "test@example.invalid",
    "city": "Zagreb", "institution": "", "message": '<img src=x onerror="alert(1)">\nDrugi redak',
}
COLUMNS = {key: index for index, key in enumerate(("submission_id", "created", "name", "email", "phone", "city", "institution", "message", "status", "assignee", "notes"), 1)}


class TablesTests(unittest.IsolatedAsyncioTestCase):
    async def asyncSetUp(self):
        self.rows = []
        self.posts = 0
        self.fail_after_insert = False
        app = web.Application()
        app.router.add_route("*", "/rows", self.request)
        self.server = TestServer(app)
        await self.server.start_server()
        self.tables = Tables({
            "url": "https://cloud.example.invalid", "table_id": 2,
            "username": "test", "password": "test-password", "columns": COLUMNS,
        })
        self.tables.url = str(self.server.make_url("/")).rstrip("/")

    async def asyncTearDown(self):
        await self.tables.close()
        await self.server.close()

    async def request(self, request):
        self.assertEqual(b64decode(request.headers["Authorization"].removeprefix("Basic ")), b"test:test-password")
        if request.method == "GET":
            offset, limit = int(request.query["offset"]), int(request.query["limit"])
            return web.json_response(self.rows[offset:offset + limit])
        self.posts += 1
        data = (await request.json())["data"]
        row = {"id": len(self.rows) + 1, "data": [{"columnId": int(key), "value": value} for key, value in data.items()]}
        self.rows.append(row)
        if self.fail_after_insert:
            self.fail_after_insert = False
            return web.json_response({"message": "Response lost after commit"}, status=503)
        return web.json_response(row)

    async def test_lost_response_is_recovered_without_duplicates_or_overwriting_human_edits(self):
        self.fail_after_insert = True
        with self.assertRaisesRegex(RuntimeError, "HTTP 503"):
            await self.tables.deliver(DATA, 0)
        notes = {"columnId": COLUMNS["notes"], "value": "Već kontaktirana osoba"}
        self.rows[0]["data"].append(notes)
        next(cell for cell in self.rows[0]["data"] if cell["columnId"] == COLUMNS["status"])["value"] = "Kontaktirano"
        self.assertEqual(await self.tables.deliver(DATA, 0), 1)
        self.assertEqual(self.posts, 1)
        self.assertIn(notes, self.rows[0]["data"])
        self.assertEqual(next(cell["value"] for cell in self.rows[0]["data"] if cell["columnId"] == COLUMNS["status"]), "Kontaktirano")

    async def test_retry_finds_application_after_first_page(self):
        self.rows = [{"id": index, "data": []} for index in range(100)]
        self.rows.append({"id": 101, "data": [{"columnId": COLUMNS["submission_id"], "value": DATA["id"]}]})
        self.assertEqual(await self.tables.deliver(DATA, 0), 101)
        self.assertEqual(self.posts, 0)

    async def test_new_row_preserves_plain_text_and_sets_initial_status(self):
        self.assertEqual(await self.tables.deliver(DATA, 0), 1)
        cells = {cell["columnId"]: cell["value"] for cell in self.rows[0]["data"]}
        self.assertEqual(cells[COLUMNS["name"]], DATA["name"])
        self.assertEqual(cells[COLUMNS["phone"]], "")
        self.assertEqual(cells[COLUMNS["created"]], "1970-01-01T01:00:00+01:00")
        self.assertEqual(cells[COLUMNS["message"]], "&lt;img src=x onerror=&quot;alert(1)&quot;&gt;<br>Drugi redak")
        self.assertEqual(cells[COLUMNS["status"]], "Novo")
        self.assertTrue(all(COLUMNS[key] not in cells for key in ("assignee", "notes")))

    async def test_plain_http_configuration_is_rejected(self):
        with self.assertRaisesRegex(RuntimeError, "HTTPS"):
            Tables({"url": "http://cloud.example.invalid"})


if __name__ == "__main__":
    unittest.main()
