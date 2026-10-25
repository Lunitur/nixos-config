import json
import urllib.error
import urllib.parse
import urllib.request


def quote(value):
    return urllib.parse.quote(value, safe="")


class MatrixError(RuntimeError):
    def __init__(self, status, code, response=None):
        super().__init__(f"Matrix HTTP {status} ({code})")
        self.status = status
        self.code = code
        self.response = response or {}


class Matrix:
    def __init__(self, homeserver, token=None):
        self.homeserver = homeserver.rstrip("/")
        self.token = token

    def request(self, method, path, data=None, content_type="application/json"):
        headers = {"Content-Type": content_type}
        if self.token:
            headers["Authorization"] = f"Bearer {self.token}"
        if data is not None and content_type == "application/json":
            data = json.dumps(data).encode()
        request = urllib.request.Request(self.homeserver + path, data=data, headers=headers, method=method)
        try:
            with urllib.request.urlopen(request, timeout=60) as response:
                return json.load(response)
        except urllib.error.HTTPError as error:
            try:
                with error:
                    response = json.load(error)
            except (ValueError, UnicodeDecodeError):
                response = {}
            raise MatrixError(error.code, response.get("errcode", "unknown"), response) from None

    def api(self, method, path, data=None):
        return self.request(method, "/_matrix/client/v3" + path, data)

    def check_room(self, room):
        try:
            self.api("GET", f"/rooms/{quote(room)}/state/m.room.encryption")
        except MatrixError as error:
            if error.status == 404 and error.code == "M_NOT_FOUND":
                return
            raise
        raise RuntimeError("Room encryption is enabled; refusing to forward plaintext mail.")

    def send(self, room, transaction, content):
        self.check_room(room)
        return self.api("PUT", f"/rooms/{quote(room)}/send/m.room.message/{quote(transaction)}", content)

    def upload(self, raw):
        return self.request("POST", "/_matrix/media/v3/upload?filename=message.eml", raw, "message/rfc822")["content_uri"]
