from base64 import b64encode
from datetime import datetime
from html import escape
from zoneinfo import ZoneInfo

from aiohttp import ClientSession, ClientTimeout


def row_values(data, created, columns):
    values = {
        "submission_id": data["id"],
        "created": datetime.fromtimestamp(created, ZoneInfo("Europe/Zagreb")).isoformat(timespec="seconds"),
        **{key: data.get(key, "") for key in ("name", "email", "phone", "city", "institution")},
        "message": escape(data.get("message", "")).replace("\n", "<br>"),
        "status": "Novo",
    }
    return {str(columns[key]): value for key, value in values.items()}


class Tables:
    def __init__(self, config):
        if not config["url"].startswith("https://"):
            raise RuntimeError("Nextcloud Tables zahtijeva HTTPS.")
        self.columns = config["columns"]
        self.url = config["url"].rstrip("/") + f"/index.php/apps/tables/api/1/tables/{int(config['table_id'])}"
        token = b64encode(f"{config['username']}:{config['password']}".encode()).decode()
        self.session = ClientSession(
            headers={"Authorization": f"Basic {token}"},
            timeout=ClientTimeout(total=30),
        )

    async def close(self):
        await self.session.close()

    async def request(self, method, path, data=None):
        async with self.session.request(method, self.url + path, json=data, allow_redirects=False) as response:
            if response.status >= 300:
                raise RuntimeError(f"Nextcloud Tables API: HTTP {response.status}.")
            return await response.json()

    async def find_submission(self, submission_id):
        offset = 0
        while True:
            rows = await self.request("GET", f"/rows?limit=100&offset={offset}")
            for row in rows:
                if any(cell["columnId"] == self.columns["submission_id"] and cell["value"] == submission_id for cell in row["data"] or []):
                    return row["id"]
            if len(rows) < 100:
                return None
            offset += len(rows)

    async def deliver(self, data, created):
        existing = await self.find_submission(data["id"])
        if existing is not None:
            return existing
        row = await self.request("POST", "/rows", {"data": row_values(data, created, self.columns)})
        return row["id"]
