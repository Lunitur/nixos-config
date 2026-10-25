import json
import os
import secrets
import subprocess
from pathlib import Path

from matrix import Matrix, MatrixError, quote


def save(path, value):
    temporary = path.with_suffix(".tmp")
    temporary.write_text(json.dumps(value))
    temporary.chmod(0o600)
    temporary.replace(path)


def register(client, account, token):
    request = {**account, "initial_device_display_name": "SUS mail forwarder"}
    for _ in range(5):
        try:
            return client.api("POST", "/register", request)
        except MatrixError as error:
            if error.status != 401:
                raise
            response = error.response
        completed = response.get("completed", [])
        flows = [flow["stages"] for flow in response.get("flows", []) if set(flow["stages"]) <= {"m.login.registration_token", "m.login.dummy"}]
        if not flows:
            raise RuntimeError("Unsupported Matrix registration challenge.")
        stage = next((stage for stage in flows[0] if stage not in completed), None)
        if not stage:
            raise RuntimeError("Matrix registration did not complete.")
        request["auth"] = {"type": stage, "session": response["session"]}
        if stage == "m.login.registration_token":
            request["auth"]["token"] = token
    raise RuntimeError("Matrix registration did not complete.")


def main():
    if os.geteuid() != 0:
        raise SystemExit("Run sudo sus-mail-setup on Nano.")
    os.umask(0o077)
    directory = Path("/var/lib/sus-mail-secrets")
    directory.mkdir(mode=0o700, exist_ok=True)
    path = directory / "bot.json"
    homeserver = os.environ["SUS_MAIL_HOMESERVER"]
    if path.exists():
        identity = json.loads(path.read_text())
        if identity["homeserver"] != homeserver:
            raise RuntimeError("The existing bot belongs to a different homeserver.")
    else:
        account_path = directory / "account.json"
        if account_path.exists():
            account = json.loads(account_path.read_text())
        else:
            account = {"username": "sus-mail", "password": secrets.token_urlsafe(48)}
            save(account_path, account)
        client = Matrix(homeserver)
        try:
            identity = client.api("POST", "/login", {
                "type": "m.login.password", "identifier": {"type": "m.id.user", "user": account["username"]},
                "password": account["password"], "initial_device_display_name": "SUS mail forwarder",
            })
        except MatrixError as error:
            if error.status != 403:
                raise
            token = Path(os.environ["SUS_MAIL_REGISTRATION_TOKEN_FILE"]).read_text().strip()
            identity = register(client, account, token)
        identity = {key: identity[key] for key in ("user_id", "access_token", "device_id")}
        identity["homeserver"] = homeserver
        save(path, identity)
    client = Matrix(homeserver, identity["access_token"])
    room = os.environ["SUS_MAIL_ROOM"]
    if room.startswith("#"):
        room = client.api("GET", "/directory/room/" + quote(room))["room_id"]
    if not room.startswith("!") or len(room) < 2:
        raise RuntimeError("Invalid Matrix room ID.")
    if identity.get("room_id") and identity["room_id"] != room:
        raise RuntimeError("The existing bot is bound to a different room.")
    identity["room_id"] = room
    save(path, identity)
    try:
        client.api("POST", "/join/" + quote(room), {})
    except MatrixError as error:
        if error.status != 403:
            raise
        print(f"Invite {identity['user_id']} to {os.environ['SUS_MAIL_ROOM']}; the bot will retry joining.")
    else:
        client.check_room(room)
        client.api("PUT", "/profile/" + quote(identity["user_id"]) + "/displayname", {"displayname": "SUS · mail"})
        print(f"Bot {identity['user_id']} joined the configured room.")
    subprocess.run(["systemctl", "restart", "sus-mail.service"], check=True)
    print("Check: systemctl status sus-mail.service")


if __name__ == "__main__":
    try:
        main()
    except Exception as error:
        reason = str(error) if isinstance(error, MatrixError) or type(error) is RuntimeError else type(error).__name__
        raise SystemExit(f"Setup did not complete ({reason}); no credentials were printed.") from None
