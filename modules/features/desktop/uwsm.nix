{
  config,
  lib,
  ...
}:
let
  cfg = config.features.desktop.uwsm;
in
{
  options.features.desktop.uwsm.enable = lib.mkEnableOption "UWSM support";

  config = lib.mkIf cfg.enable {
    programs.uwsm.enable = true;
  };
}