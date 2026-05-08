{ ... }:
{
  flake.homeModules.common-theme-stylix =
    { config, pkgs, ... }:
    {
      gtk.gtk4.theme = config.gtk.theme;
      stylix.targets = {
        firefox.profileNames = [ "default" ];
        waybar.enable = false;
      };
    };

  flake.nixosModules.common-theme-stylix =
    {
      config,
      lib,
      pkgs,
      ...
    }:
    let
      colors = import ./_green.nix;
    in
    {
      programs.dconf.enable = true;
      gtk.iconCache.enable = true;
      programs.gdk-pixbuf.modulePackages = [ pkgs.librsvg ];
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
            name = "Iosevka";
            package = pkgs.nerd-fonts.iosevka;
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

        targets.nixos-icons.enable = true;

        icons = {
          enable = true;
          package = pkgs.papirus-icon-theme;
          dark = "Papirus-Dark";
          light = "Papirus-Light";
        };
      };
    };
}
