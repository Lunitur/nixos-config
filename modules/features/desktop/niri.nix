{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.features.desktop.niri;
in
{
  options.features.desktop.niri.enable = lib.mkEnableOption "Niri desktop";

  config = lib.mkIf cfg.enable {
    programs.niri.enable = true;
    home-manager.users.carjin = {
      imports = [ ./niri_home ];
    };
  };
}
