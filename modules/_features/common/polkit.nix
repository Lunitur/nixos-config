{
  config,
  lib,
  ...
}:
let
  cfg = config.features.common.polkit;
in
{
  options.features.common.polkit.enable = lib.mkEnableOption "Polkit";

  config = lib.mkIf cfg.enable {
    security.polkit.enable = true;
  };
}