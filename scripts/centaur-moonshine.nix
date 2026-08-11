{ pkgs }:

# Stop user-level Sunshine streaming server on centaur, start system-level
# Moonshine streaming server (run from the desktop machine).
pkgs.writeShellScriptBin "centaur-moonshine" ''
  set -euo pipefail

  ssh -t lsimek@centaur '
    print "Stopping sunshine.service"
    with-env { XDG_RUNTIME_DIR: $"/run/user/(id -u | str trim)" } { systemctl --user stop sunshine.service }

    print "Starting moonshine.service"
    sudo systemctl start moonshine.service

    print "--- status ---"
    try { with-env { XDG_RUNTIME_DIR: $"/run/user/(id -u | str trim)" } { systemctl --user is-active sunshine.service } } catch {}
    try { systemctl is-active moonshine.service } catch {}
  '
''
