{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.features.apps.zathura;
in
{
  options.features.apps.zathura.enable = lib.mkEnableOption "Zathura document viewer";

  config = lib.mkIf cfg.enable {
    home-manager.users.carjin = {
      programs.zathura = {
        enable = true;
        mappings = {
          D = "toggle_page_mode";
          d = "scroll half_down";
          u = "scroll half_up";
        };
        options = {
          font = "Iosevka Bold 13";
          # copy selection to system clipboard
          selection-clipboard = "clipboard";
          incremental-search = true;
        };
        package = pkgs.zathura.override { useMupdf = true; };
      };
    };
  };
}