{ pkgs }:

# Stop system-level Moonshine streaming server on centaur, start user-level
# Sunshine streaming server (run from the desktop machine).
pkgs.writeShellScriptBin "centaur-tailscale" ''
  set -euo pipefail

  ssh -t lsimek@centaur '
    sudo systemctl restart tailscaled.service
  '
''
