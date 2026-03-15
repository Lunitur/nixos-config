{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.features.desktop.waybar;
in
{
  options.features.desktop.waybar.enable = lib.mkEnableOption "Waybar";

  config = lib.mkIf cfg.enable {
    home-manager.users.carjin = {
      imports = [ ./waybar.nix ];
    };
  };
}