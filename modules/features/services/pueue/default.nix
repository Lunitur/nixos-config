{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.features.services.pueue;
in
{
  options.features.services.pueue.enable = lib.mkEnableOption "Pueue service";

  config = lib.mkIf cfg.enable {
    home-manager.users.carjin = {
      imports = [ ./pueue.nix ];
    };
  };
}
