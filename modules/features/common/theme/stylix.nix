{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.features.common.theme.stylix;
  colors = import ./green.nix;
in
{
  options.features.common.theme.stylix.enable = lib.mkEnableOption "Stylix";

  config = lib.mkIf cfg.enable {
    stylix = {
      enable = true;
      polarity = "dark";
      base16Scheme = {
        scheme = colors.scheme;
        author = colors.author;

        base00 = colors.background;
        base01 = colors.mantle;
        base02 = colors.grey-dark;
        base03 = colors.grey;
        base04 = colors.grey-light;
        base05 = colors.text;
        base06 = colors.primary-pale;
        base07 = colors.highlight;
        base08 = colors.error;
        base09 = colors.success;
        base0A = colors.yellow;
        base0B = colors.secondary;
        base0C = colors.info;
        base0D = colors.primary;
        base0E = colors.warning;
        base0F = colors.purple;
      };

      cursor = {
        name = "DMZ-Black";
        size = 10;
        package = pkgs.vanilla-dmz;
      };

      fonts = {
        emoji = {
          name = "Noto Color Emoji";
          package = pkgs.noto-fonts-color-emoji;
        };
        monospace = {
          name = "JetBrains Mono";
          package = pkgs.nerd-fonts.jetbrains-mono;
        };
        sansSerif = {
          name = "Noto Sans";
          package = pkgs.noto-fonts;
        };
        serif = {
          name = "Noto Serif";
          package = pkgs.noto-fonts;
        };

        sizes = {
          terminal = 13;
          applications = 11;
        };
      };

      image = ./wallpapers/desktop6.png;

      iconTheme = {
        enable = true;
        package = pkgs.papirus-icon-theme;
        dark = "Papirus-Dark";
        light = "Papirus-Light";
      };
    };

    home-manager.users.carjin = {
      stylix.targets = {
        firefox.profileNames = [ "default" ];
        waybar.enable = false;
        # hyprland.enable = false;
        # hyprlock.enable = false;
        vscode.enable = false;
        # wofi.enable = false;
        # libreoffice.enable = false;
      };
    };
  };
}
