{
  config,
  lib,
  pkgs,
  ...
}:
{
  flake.homeModules.tmux =
    { pkgs, ... }:
    {
      programs.tmux = {
        enable = true;
        shortcut = "a"; # Changes prefix to Ctrl + a (often preferred by Emacs users)
        baseIndex = 1; # Start window numbers at 1 instead of 0
        escapeTime = 0; # Removes delay when pressing ESC in Vim/Doom Emacs
        plugins = with pkgs.tmuxPlugins; [
          resurrect # Allows saving/restoring sessions across reboots
          continuum # Automates resurrect
        ];
      };

      # Named tmux-daemon, not tmux: the continuum plugin hardcodes
      # `systemctl --user disable tmux.service` on every server start, which
      # removes both this unit's link and its default.target.wants entry.
      systemd.user.services.tmux-daemon = {
        Unit = {
          Description = "Tmux Server";
        };
        Service = {
          # oneshot + RemainAfterExit: unit is "up" as soon as the detached
          # session exists. Type=forking made systemd wait on the tmux client
          # and time out. The has-session guard keeps restarts idempotent
          # (plain `new-session -s daemon` exits 1 with "duplicate session").
          Type = "oneshot";
          RemainAfterExit = true;
          ExecStart = "${pkgs.bash}/bin/bash -c '${pkgs.tmux}/bin/tmux has-session -t daemon 2>/dev/null || ${pkgs.tmux}/bin/tmux new-session -s daemon -d'";
          ExecStop = "${pkgs.tmux}/bin/tmux kill-server";
        };
        Install = {
          WantedBy = [ "default.target" ];
        };
      };
    };

  flake.nixosModules.tmux =
    { pkgs, ... }:
    {
      users.users.carjin.linger = true;
    };
}
