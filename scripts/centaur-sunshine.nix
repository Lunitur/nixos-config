{ pkgs }:

# Stop system-level Moonshine streaming server on centaur, start user-level
# Sunshine streaming server (run from the desktop machine).
pkgs.writeShellScriptBin "centaur-sunshine" ''
  set -euo pipefail

  ssh -t lsimek@centaur '
    let uid = (id -u | str trim)

    sudo systemctl stop moonshine.service

    print "Starting sunshine.service"
    with-env { XDG_RUNTIME_DIR: $"/run/user/($uid)" } {
        systemctl --user restart sunshine.service
    }

    print "--- status ---"
    let moonshine_status = (systemctl is-active moonshine.service | complete)
    print $moonshine_status.stdout

    with-env { XDG_RUNTIME_DIR: $"/run/user/($uid)" } {
        let sunshine_status = (systemctl --user is-active sunshine.service | complete)
        print $sunshine_status.stdout
    }
  '
''
