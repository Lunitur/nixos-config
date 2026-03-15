{
  config,
  lib,
  ...
}:
let
  cfg = config.features.shell.nushell;
in
{
  options.features.shell.nushell.enable = lib.mkEnableOption "Nushell";

  config = lib.mkIf cfg.enable {
    home-manager.users.carjin = {
      imports = [ ./nushell.nix ];
    };
  };
}