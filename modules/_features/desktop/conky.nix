{
  config,
  lib,
  ...
}:
let
  cfg = config.features.desktop.conky;
in
{
  options.features.desktop.conky.enable = lib.mkEnableOption "Conky system monitor";

  config = lib.mkIf cfg.enable {
    home-manager.users.carjin = {
      services.conky.enable = true;
    };
  };
}