import argparse
import json
import os
import secrets
import subprocess
import urllib.error
import urllib.parse
import urllib.request
from pathlib import Path


def api(homeserver, method, path, data=None, token=None):
    headers = {"Content-Type": "application/json"}
    if token:
        headers["Authorization"] = f"Bearer {token}"
    request = urllib.request.Request(homeserver + "/_matrix/client/v3" + path, method=method, headers=headers, data=json.dumps(data).encode() if data is not None else None)
    try:
        with urllib.request.urlopen(request, timeout=30) as response:
            return response.status, json.load(response)
    except urllib.error.HTTPError as error:
        return error.code, json.load(error)


def save(path, data):
    temporary = path.with_suffix(".tmp")
    temporary.write_text(json.dumps(data))
    temporary.chmod(0o600)
    temporary.replace(path)


def register(homeserver, name, password, token):
    request = {"username": name, "password": password, "initial_device_display_name": "SUS prijave"}
    for _ in range(5):
        status, response = api(homeserver, "POST", "/register", request)
        if status == 200:
            return response
        if status != 401:
            raise RuntimeError(f"Registracija nije uspjela ({response.get('errcode', status)}).")
        completed = response.get("completed", [])
        flows = [flow["stages"] for flow in response.get("flows", []) if set(flow["stages"]) <= {"m.login.registration_token", "m.login.dummy"}]
        if not flows:
            raise RuntimeError("Server traži nepodržanu provjeru registracije.")
        stage = next((stage for stage in flows[0] if stage not in completed), None)
        if not stage:
            raise RuntimeError("Server nije dovršio registraciju.")
        request["auth"] = {"type": stage, "session": response["session"]}
        if stage == "m.login.registration_token":
            request["auth"]["token"] = token
    raise RuntimeError("Registracija nije dovršena.")


def main():
    parser = argparse.ArgumentParser(description="Postavi SUS Matrix bot bez ispisivanja tajni.")
    parser.add_argument("room", nargs="?", default=os.environ["SUS_MEMBERSHIP_ROOM"])
    parser.add_argument("--username", default="sus-prijave")
    args = parser.parse_args()
    if os.geteuid() != 0:
        raise SystemExit("Pokreni sa sudo na Nanou.")
    os.umask(0o077)
    directory = Path("/var/lib/sus-membership-secrets")
    directory.mkdir(mode=0o700, exist_ok=True)
    identity_path = directory / "bot.json"
    if identity_path.exists():
        identity = json.loads(identity_path.read_text())
    else:
        homeserver = os.environ["SUS_MEMBERSHIP_HOMESERVER"]
        account_path = directory / "account.json"
        if account_path.exists():
            account = json.loads(account_path.read_text())
        else:
            account = {"username": args.username, "password": secrets.token_urlsafe(48)}
            save(account_path, account)
        # A saved password allows recovery if registration succeeded before a connection failed.
        status, response = api(homeserver, "POST", "/login", {
            "type": "m.login.password", "identifier": {"type": "m.id.user", "user": account["username"]},
            "password": account["password"], "initial_device_display_name": "SUS prijave",
        })
        if status != 200:
            registration_token = Path(os.environ["SUS_MEMBERSHIP_REGISTRATION_TOKEN_FILE"]).read_text().strip()
            response = register(homeserver, account["username"], account["password"], registration_token)
        identity = {"credentials": {
            "id": response["user_id"], "homeserver": homeserver,
            "access_token": response["access_token"], "device_id": response["device_id"],
        }, "pickle_key": secrets.token_urlsafe(48)}
        save(identity_path, identity)
    credentials = identity["credentials"]
    room = args.room
    if room.startswith("#"):
        status, response = api(credentials["homeserver"], "GET", "/directory/room/" + urllib.parse.quote(room, safe=""), token=credentials["access_token"])
        if status != 200:
            raise RuntimeError(f"Soba nije pronađena ({response.get('errcode', status)}).")
        room = response["room_id"]
    if not isinstance(room, str) or not room.startswith("!") or len(room) < 2:
        raise RuntimeError("Navedi valjani ID ili alias sobe.")
    if identity.get("room_id") and identity["room_id"] != room:
        raise RuntimeError("Bot je već vezan uz drugu sobu. Promjenu odredišta treba uskladiti s postojećim prijavama.")
    identity["room_id"] = room
    save(identity_path, identity)
    status, response = api(credentials["homeserver"], "POST", "/join/" + urllib.parse.quote(room, safe=""), {}, credentials["access_token"])
    if status != 200:
        print(f"Pozovi {credentials['id']} u ciljnu sobu. Servis će prihvatiti taj poziv.")
    else:
        print(f"Bot {credentials['id']} povezan je s ciljnom sobom.")
    subprocess.run(["systemctl", "restart", "sus-membership.service"], check=True)
    print("Provjera: systemctl status sus-membership.service")


if __name__ == "__main__":
    try:
        main()
    except (RuntimeError, OSError, KeyError, ValueError) as error:
        if isinstance(error, RuntimeError):
            raise SystemExit(str(error))
        raise SystemExit(f"Postavljanje nije dovršeno ({type(error).__name__}). Tajne nisu ispisane.")
