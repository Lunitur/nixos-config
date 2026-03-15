{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.features.desktop.thunar;
in
{
  options.features.desktop.thunar.enable = lib.mkEnableOption "Thunar file manager";

  config = lib.mkIf cfg.enable {
    programs.thunar = {
      enable = true;
      plugins = with pkgs.xfce; [
        thunar-archive-plugin
        thunar-volman
      ];
    };

    services.gvfs.enable = true; # Mount, trash, and other functionalities
    services.tumbler.enable = true; # Thumbnail support for images
  };
}