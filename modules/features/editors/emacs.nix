{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.features.editors.emacs;
in
{
  options.features.editors.emacs.enable = lib.mkEnableOption "Emacs editor";

  config = lib.mkIf cfg.enable {
    home-manager.users.carjin = {
      programs.emacs = {
        enable = true;
        package = pkgs.emacs-pgtk;
      };
      services.emacs.enable = true;

      home.sessionPath = [
        "$HOME/.config/emacs/bin"
      ];

      home.packages = with pkgs; [
        ripgrep
        coreutils
        fd
      ];
    };
  };
}