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
    home-manager.users.carjin = {
      home.packages =
        with pkgs;
        [
          dejavu_fonts
          jetbrains-mono
          noto-fonts
          noto-fonts-color-emoji
          fira-code
          source-code-pro
          nanum-gothic-coding
        ]
        ++ (lib.filter lib.isDerivation (builtins.attrValues pkgs.nerd-fonts));

      fonts.fontconfig.enable = true;
    };
  };
}