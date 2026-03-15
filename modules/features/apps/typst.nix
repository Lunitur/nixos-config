{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.features.apps.typst;
in
{
  options.features.apps.typst.enable = lib.mkEnableOption "Typst typesetting";

  config = lib.mkIf cfg.enable {
    home-manager.users.carjin = {
      home.packages = with pkgs; [
        typst
        tinymist
        typstyle
      ];
    };
  };
}