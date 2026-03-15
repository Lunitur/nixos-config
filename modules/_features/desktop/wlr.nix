{
  config,
  lib,
  ...
}:
let
  cfg = config.features.desktop.wlr;
in
{
  options.features.desktop.wlr.enable = lib.mkEnableOption "WLR portal";

  config = lib.mkIf cfg.enable {
    xdg.portal.wlr.enable = true;
  };
}