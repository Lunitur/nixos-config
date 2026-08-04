{ pkgs }:

# Stop user-level Sunshine streaming server on centaur, start system-level
# Moonshine streaming server (run from the desktop machine).
pkgs.writeShellScriptBin "centaur-moonshine" ''
  set -euo pipefail

  ssh -t lsimek@centaur '
    set -e
    echo "Stopping sunshine.service"
    XDG_RUNTIME_DIR=/run/user/$(id -u) systemctl --user stop sunshine.service
    echo "Starting moonshine.service"
    sudo systemctl start moonshine.service
    echo "--- status ---"
    XDG_RUNTIME_DIR=/run/user/$(id -u) systemctl --user is-active sunshine.service || true
    systemctl is-active moonshine.service || true
  '
''
