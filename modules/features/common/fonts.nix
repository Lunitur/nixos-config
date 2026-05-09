{ ... }:
{
  flake.homeModules.common-fonts =
    { ... }:
    {
      fonts.fontconfig.enable = true;
    };

  flake.nixosModules.common-fonts =
    {
      config,
      lib,
      pkgs,
      ...
    }:
    {
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
          nerd-fonts.symbols-only
        ];
        # ++ (lib.filter lib.isDerivation (builtins.attrValues pkgs.nerd-fonts));

        fontconfig = {
          enable = true;
          defaultFonts = {
            monospace = [ "Iosevka" ];
            sansSerif = [ "Noto Sans" ];
            serif = [ "Noto Serif" ];
          };
        };
      };
    };
}
