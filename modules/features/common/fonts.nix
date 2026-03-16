{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.features.common.fonts;
in
{
  options.features.common.fonts.enable = lib.mkEnableOption "User fonts";

  config = lib.mkIf cfg.enable {
    fonts = {
      packages = with pkgs; [
        dejavu_fonts
        jetbrains-mono
        noto-fonts
        noto-fonts-color-emoji
        fira-code
        iosevka
        source-code-pro
        nanum-gothic-coding
      ] ++ (lib.filter lib.isDerivation (builtins.attrValues pkgs.nerd-fonts));

      fontconfig = {
        enable = true;
        defaultFonts = {
          monospace = [ "Iosevka" ];
          sansSerif = [ "Noto Sans" ];
          serif = [ "Noto Serif" ];
        };
      };
    };

    home-manager.users.carjin = {
      fonts.fontconfig.enable = true;
    };
  };
}