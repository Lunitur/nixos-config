{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.features.services.udiskie;
in
{
  options.features.services.udiskie.enable = lib.mkEnableOption "Udiskie service";

  config = lib.mkIf cfg.enable {
    home-manager.users.carjin = {
      imports = [ ./udiskie.nix ];
    };
  };
}
