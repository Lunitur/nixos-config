import argparse
import base64
import json
import os
import re
import subprocess
import urllib.error
import urllib.request
from pathlib import Path


TITLE = "SUS · prijave za članstvo"
COLUMNS = [
    {"technicalName": "submission_id", "title": "ID prijave", "textMaxLength": 64, "textUnique": True, "mandatory": True},
    {"technicalName": "created", "title": "Datum prijave", "type": "datetime", "subtype": ""},
    {"technicalName": "name", "title": "Ime i prezime", "textMaxLength": 120},
    {"technicalName": "email", "title": "E-mail", "textMaxLength": 254},
    {"technicalName": "phone", "title": "Broj mobitela", "textMaxLength": 40},
    {"technicalName": "city", "title": "Mjesto", "textMaxLength": 120},
    {"technicalName": "institution", "title": "Škola / fakultet", "textMaxLength": 180},
    {"technicalName": "message", "title": "Poruka", "subtype": "rich"},
    {"technicalName": "status", "title": "Status", "textDefault": "Novo", "textMaxLength": 100},
    {"technicalName": "assignee", "title": "Zadužena osoba", "textMaxLength": 120},
    {"technicalName": "notes", "title": "Bilješke", "subtype": "rich"},
]


def save(path, config):
    temporary = path.with_suffix(".tmp")
    temporary.write_text(json.dumps(config, ensure_ascii=False))
    temporary.chmod(0o600)
    temporary.replace(path)


def occ(*arguments):
    result = subprocess.run(
        ["nextcloud-occ", "--no-interaction", "--no-ansi", *arguments],
        capture_output=True, text=True, check=True,
    )
    return result.stdout


def api(config, method, path, data=None):
    token = base64.b64encode(f"{config['username']}:{config['password']}".encode()).decode()
    request = urllib.request.Request(
        config["url"] + "/index.php/apps/tables/api/1" + path,
        method=method,
        headers={"Authorization": f"Basic {token}", "Content-Type": "application/json", "Accept": "application/json"},
        data=json.dumps(data).encode() if data is not None else None,
    )
    try:
        with urllib.request.urlopen(request, timeout=30) as response:
            return json.load(response)
    except urllib.error.HTTPError as error:
        raise RuntimeError(f"Nextcloud Tables API: HTTP {error.code} ({method} {path}).") from None
    except urllib.error.URLError:
        raise RuntimeError("Nije moguće pristupiti Nextcloud Tables API-ju.") from None


def configure(config, share_users, path):
    tables = api(config, "GET", "/tables")
    if "table_id" in config:
        matches = [table for table in tables if table["id"] == config["table_id"]]
    else:
        matches = [table for table in tables if table["title"] == TITLE and table["ownership"] == config["username"]]
    if len(matches) > 1:
        raise RuntimeError("Pronađeno je više SUS tablica. Odredište treba provjeriti ručno.")
    if "table_id" in config and not matches:
        raise RuntimeError("Postojeća SUS tablica nije dostupna. Odredište nije promijenjeno.")
    table = matches[0] if matches else api(config, "POST", "/tables", {"title": TITLE, "emoji": "", "template": "custom"})
    if table["ownership"] != config["username"]:
        raise RuntimeError("SUS tablica mora pripadati botu.")
    config = {**config, "table_id": table["id"]}
    save(path, config)
    base = f"/tables/{table['id']}"

    shares = api(config, "GET", base + "/shares")
    if any(share["receiverType"] != "user" or share["receiver"] not in share_users for share in shares):
        raise RuntimeError("Tablica je već podijeljena s drugim korisnicima. Provjeri dijeljenje prije nastavka.")

    existing = api(config, "GET", base + "/columns")
    columns = {}
    for specification in COLUMNS:
        desired = {"type": "text", "subtype": "line", "mandatory": False, **specification}
        matches = [column for column in existing if column["technicalName"] == desired["technicalName"]]
        if len(matches) > 1:
            raise RuntimeError(f"Više stupaca koristi naziv {desired['technicalName']}.")
        column = matches[0] if matches else api(config, "POST", base + "/columns", desired)
        if any(column[key] != desired[key] for key in ("type", "subtype")):
            raise RuntimeError(f"Stupac {desired['technicalName']} ima neočekivan tip.")
        if desired.get("textUnique") and not column.get("textUnique"):
            raise RuntimeError("ID prijave mora biti jedinstven. Provjeri postavke stupca.")
        columns[desired["technicalName"]] = column["id"]
    for user in share_users:
        share = next((share for share in shares if share["receiver"] == user), None)
        if share:
            if not share["permissionRead"] or not share["permissionUpdate"]:
                raise RuntimeError(f"Korisnik {user} nema ovlasti čitanja i uređivanja. Provjeri dijeljenje.")
            continue
        api(config, "POST", base + "/shares", {
            "receiver": user, "receiverType": "user",
            "permissionRead": True, "permissionCreate": True, "permissionUpdate": True,
            "permissionDelete": False, "permissionManage": False,
        })
    config = {**config, "columns": columns, "share_users": share_users}
    save(path, config)
    return config


def main():
    parser = argparse.ArgumentParser(description="Postavi SUS tablicu i spremi API vjerodajnice bez ispisivanja tajni.")
    parser.add_argument("--url", default="https://nextcloud.autonomija.net")
    parser.add_argument("--username", default="sus-prijave")
    parser.add_argument("--share-user", action="append", required=True)
    args = parser.parse_args()
    if os.geteuid() != 0:
        raise RuntimeError("Pokreni sa sudo na Nanou.")
    if not args.url.startswith("https://"):
        raise RuntimeError("Nextcloud URL mora koristiti HTTPS.")
    os.umask(0o077)
    for user in dict.fromkeys([args.username, *args.share_user]):
        occ("user:info", user)
    directory = Path("/var/lib/sus-membership-secrets")
    directory.mkdir(mode=0o700, exist_ok=True)
    path = directory / "nextcloud.json"
    if path.exists():
        config = json.loads(path.read_text())
        if (config["url"], config["username"]) != (args.url.rstrip("/"), args.username):
            raise RuntimeError("Postojeće vjerodajnice koriste drugi račun ili URL. Odredište nije promijenjeno.")
    else:
        output = occ("user:auth-tokens:add", "--name", "SUS prijave · Tables", args.username)
        password = output.strip().splitlines()[-1]
        if not re.fullmatch(r"[A-Za-z0-9]{72}", password):
            raise RuntimeError("Nextcloud nije vratio očekivani API token. Tajne nisu ispisane.")
        config = {"url": args.url.rstrip("/"), "username": args.username, "password": password}
        save(path, config)
    config = configure(config, list(dict.fromkeys(args.share_user)), path)
    print(f"Tablica: {TITLE} (ID {config['table_id']}).")
    print(f"Otvori: {config['url']}/index.php/apps/tables/")
    print(f"Uređivanje: {', '.join(config['share_users'])}.")
    print("API vjerodajnice spremljene su lokalno. Automatska dostava još nije uključena.")


if __name__ == "__main__":
    try:
        main()
    except (RuntimeError, OSError, ValueError, KeyError, subprocess.CalledProcessError) as error:
        if isinstance(error, RuntimeError):
            raise SystemExit(str(error))
        raise SystemExit(f"Postavljanje nije dovršeno ({type(error).__name__}). Tajne nisu ispisane.")
