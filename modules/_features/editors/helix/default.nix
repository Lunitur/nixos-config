{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.features.editors.helix;
in
{
  options.features.editors.helix.enable = lib.mkEnableOption "Helix editor";

  config = lib.mkIf cfg.enable {
    home-manager.users.carjin = {
      imports = [ ./helix.nix ];
    };
  };
}
