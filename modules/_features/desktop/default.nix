{ lib, ... }:
{
  imports = [
    ./conky.nix
    ./cosmic.nix
    ./foot.nix
    ./fuzzel.nix
    ./hyprland.nix
    ./kitty.nix
    ./mako.nix
    ./niri.nix
    ./rofi.nix
    ./swaync.nix
    ./thunar.nix
    ./uwsm.nix
    ./waybar
    ./wlr.nix
  ];

    features.hardware.audio.enable = lib.mkDefault true;

    features.common.polkit.enable = lib.mkDefault true;

  }

  