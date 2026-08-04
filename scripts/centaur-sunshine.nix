{ pkgs }:

# Stop system-level Moonshine streaming server on centaur, start user-level
# Sunshine streaming server (run from the desktop machine).
pkgs.writeShellScriptBin "centaur-sunshine" ''
  set -euo pipefail

  ssh -t lsimek@centaur '
    set -e
    echo "Stopping moonshine.service"
    sudo systemctl stop moonshine.service
    echo "Starting sunshine.service"
    XDG_RUNTIME_DIR=/run/user/$(id -u) systemctl --user start sunshine.service
    echo "--- status ---"
    systemctl is-active moonshine.service || true
    XDG_RUNTIME_DIR=/run/user/$(id -u) systemctl --user is-active sunshine.service || true
  '
''
