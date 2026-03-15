{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.features.shell.scripts;
  scripts = import ./scripts.nix { inherit pkgs lib; };
in
{
  options.features.shell.scripts.enable = lib.mkEnableOption "User scripts";

  config = lib.mkIf cfg.enable {
    home-manager.users.carjin = {
      home.packages = [
        scripts.screenshot
        scripts.lorem
        scripts.blocks
      ];
    };
  };
}