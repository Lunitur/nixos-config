{ pkgs, ... }:
{
  imports = [
    ./binds.nix
    ./startup.nix
    ./outputs.nix
    ./window-rules.nix
    ./idle.nix
    ./lock.nix
    ./sunset.nix
    ./inputs.nix
  ];

  home.packages = with pkgs; [
    swaybg
    networkmanagerapplet
    wlr-randr
    pavucontrol
    brightnessctl
    cliphist
    wl-clipboard
    playerctl
  ];
}
