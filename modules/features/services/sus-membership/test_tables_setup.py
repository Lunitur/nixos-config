import contextlib
import io
import json
import os
import tempfile
import unittest
from pathlib import Path
from unittest.mock import patch

import setup_tables


class TableSetupTests(unittest.TestCase):
    def setUp(self):
        self.directory = tempfile.TemporaryDirectory()
        self.addCleanup(self.directory.cleanup)
        self.path = Path(self.directory.name, "nextcloud.json")
        self.config = {"url": "https://cloud.example.invalid", "username": "sus-prijave", "password": "test-secret"}
        self.tables = []
        self.columns = []
        self.shares = []

    def api(self, config, method, path, data=None):
        if path == "/tables":
            if method == "POST":
                self.tables.append({"id": 7, "title": data["title"], "ownership": config["username"]})
                return self.tables[-1]
            return self.tables
        if path.endswith("/columns"):
            if method == "POST":
                if data["technicalName"] in {"id", "created_by", "created_at", "last_edit_by", "last_edit_at", "data"}:
                    raise RuntimeError("Nextcloud Tables API: HTTP 400 (Technical name is reserved).")
                self.columns.append({**data, "id": len(self.columns) + 1})
                return self.columns[-1]
            return self.columns
        if path.endswith("/shares"):
            if method == "POST":
                self.shares.append({**data, "id": len(self.shares) + 1})
                return self.shares[-1]
            return self.shares
        self.fail(f"Unexpected API request: {method} {path}")

    def test_restart_after_partial_setup_preserves_table_columns_and_credentials(self):
        def interrupted(config, method, path, data=None):
            result = self.api(config, method, path, data)
            if method == "POST" and path.endswith("/columns") and len(self.columns) == 3:
                raise RuntimeError("Response lost after committing column")
            return result

        with patch.object(setup_tables, "api", side_effect=interrupted):
            with self.assertRaises(RuntimeError):
                setup_tables.configure(self.config, ["root", "k"], self.path)
        self.assertEqual(len(self.columns), 3)
        saved = json.loads(self.path.read_text())
        self.assertEqual(saved["table_id"], 7)
        with patch.object(setup_tables, "api", side_effect=self.api):
            config = setup_tables.configure(saved, ["root", "k"], self.path)
            setup_tables.configure(config, ["root", "k"], self.path)
        self.assertEqual(len(self.tables), 1)
        self.assertEqual(len(self.columns), len(setup_tables.COLUMNS))
        self.assertIn("submission_id", config["columns"])
        self.assertEqual([share["receiver"] for share in self.shares], ["root", "k"])
        self.assertTrue(all(share["permissionRead"] and share["permissionUpdate"] for share in self.shares))
        self.assertTrue(all(not share["permissionDelete"] and not share["permissionManage"] for share in self.shares))
        self.assertEqual(config["password"], "test-secret")
        self.assertEqual(self.path.stat().st_mode & 0o777, 0o600)

    def test_unexpected_shares_prevent_provisioning_without_revoking_access(self):
        self.tables = [{"id": 7, "title": setup_tables.TITLE, "ownership": "sus-prijave"}]
        self.shares = [{"receiver": "everyone", "receiverType": "group"}]
        with patch.object(setup_tables, "api", side_effect=self.api):
            with self.assertRaisesRegex(RuntimeError, "podijeljena"):
                setup_tables.configure(self.config, ["root", "k"], self.path)
        self.assertEqual(self.columns, [])
        self.assertEqual(self.shares, [{"receiver": "everyone", "receiverType": "group"}])

    def test_missing_saved_table_never_silently_creates_a_replacement(self):
        with patch.object(setup_tables, "api", side_effect=self.api):
            with self.assertRaisesRegex(RuntimeError, "nije dostupna"):
                setup_tables.configure({**self.config, "table_id": 7}, ["root", "k"], self.path)
        self.assertEqual(self.tables, [])

    def test_token_is_saved_without_printing_and_is_reused(self):
        token = "a" * 72
        def occ(*arguments):
            return "No password provided.\napp password:\n" + token if arguments[0] == "user:auth-tokens:add" else "Account exists"

        original_umask = os.umask(0o077)
        self.addCleanup(os.umask, original_umask)
        with (
            patch.object(setup_tables, "Path", return_value=Path(self.directory.name)),
            patch.object(setup_tables.os, "geteuid", return_value=0),
            patch.object(setup_tables, "occ", side_effect=occ) as command,
            patch.object(setup_tables, "api", side_effect=self.api),
            patch("sys.argv", ["setup", "--share-user", "root", "--share-user", "k"]),
            contextlib.redirect_stdout(io.StringIO()) as output,
        ):
            setup_tables.main()
            setup_tables.main()
        self.assertEqual(sum(call.args[0] == "user:auth-tokens:add" for call in command.call_args_list), 1)
        self.assertNotIn(token, output.getvalue())
        self.assertEqual(json.loads(self.path.read_text())["password"], token)


if __name__ == "__main__":
    unittest.main()
