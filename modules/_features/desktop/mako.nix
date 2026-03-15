{
  config,
  lib,
  ...
}:
let
  cfg = config.features.desktop.mako;
in
{
  options.features.desktop.mako.enable = lib.mkEnableOption "Mako notification daemon";

  config = lib.mkIf cfg.enable {
    home-manager.users.carjin = {
      services.mako = {
        enable = true;
        anchor = "bottom-right";
        width = 350;
        margin = "0,20,20";
        borderSize = 1;
        borderRadius = 5;
        defaultTimeout = 10000;
        groupBy = "summary";
        icons = true;
      };
    };
  };
}