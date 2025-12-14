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

  # xdg.portal = {
  #   enable = true;
  #   extraPortals = with pkgs; [
  #     xdg-desktop-portal-wlr
  #     xdg-desktop-portal-gtk
  #   ];
  #   config = {
  #     common = {
  #       default = [ "wlr" "gtk" ];
  #     };
  #   };
  # };

  programs.niri.settings.environment = {
    "NIXOS_OZONE_WL" = "1";
    "ELECTRON_OZONE_PLATFORM_HINT" = "auto";
  };

  home.packages = with pkgs; [
    loupe
    swaybg
    networkmanagerapplet
    wlr-randr
    pavucontrol
    brightnessctl
    cliphist
    wl-clipboard
    playerctl
    xwayland-satellite
    nautilus # required for file picker to work
    mission-center
    imv
  ];
}
