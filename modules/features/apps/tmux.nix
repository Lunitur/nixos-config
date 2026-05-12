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
    };
}
