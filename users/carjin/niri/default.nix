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

  programs.niri.settings.environment = {
    "NIXOS_OZONE_WL" = "1";
    "ELECTRON_OZONE_PLATFORM_HINT" = "auto";
  };

  home.packages = with pkgs; [
    swaybg
    networkmanagerapplet
    wlr-randr
    pavucontrol
    brightnessctl
    cliphist
    wl-clipboard
    playerctl
    xwayland-satellite
  ];
}
