import json
import os
from pathlib import Path


def main():
    credentials = Path(os.environ["CREDENTIALS_DIRECTORY"])
    identity = json.loads((credentials / "bot.json").read_text())
    matrix_credentials = dict(identity["credentials"])
    if os.environ.get("SUS_MEMBERSHIP_REQUIRE_ENCRYPTION") != "1":
        matrix_credentials["device_id"] = None
    settings = {
        "user": {
            "credentials": matrix_credentials, "sync": True, "appservice": False,
            "hs_token": None, "autojoin": False, "displayname": "SUS · prijave za članstvo",
            "avatar_url": "disable", "ignore_initial_sync": True, "ignore_first_sync": True,
        },
        "server": {
            "hostname": "127.0.0.1", "port": int(os.environ["SUS_MEMBERSHIP_PORT"]),
            "base_path": "/", "public_url": f"http://127.0.0.1:{os.environ['SUS_MEMBERSHIP_PORT']}",
        },
        "database": "sqlite:maubot.sqlite", "database_opts": {},
        "crypto_db_pickle_key": identity["pickle_key"],
        "logging": {
            "version": 1, "disable_existing_loggers": False,
            "handlers": {"console": {"class": "logging.StreamHandler"}},
            "loggers": {"mau": {"level": "WARNING"}, "maubot": {"level": "INFO"}, "aiohttp": {"level": "WARNING"}},
            "root": {"level": "INFO", "handlers": ["console"]},
        },
    }
    Path(os.environ["RUNTIME_DIRECTORY"], "config.yaml").write_text(json.dumps(settings))


if __name__ == "__main__":
    main()
