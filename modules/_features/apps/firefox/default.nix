{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.features.apps.firefox;
in
{
  options.features.apps.firefox.enable = lib.mkEnableOption "Firefox browser";

  config = lib.mkIf cfg.enable {
    home-manager.users.carjin = {
      imports = [ ./firefox.nix ];
    };
  };
}
