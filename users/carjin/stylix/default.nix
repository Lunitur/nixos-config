#TODO: get rid of stylix
{
  pkgs,
  pkgs-unstable,
  config,
  inputs,
  ...
}:
{
  # imports = [ inputs.stylix.homeManagerModules.stylix ];

  stylix = {
    enable = true;
    polarity = "dark";
    base16Scheme = import ./scheme.nix;

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

    image = builtins.fetchurl {
      url = "https://images5.alphacoders.com/135/thumb-1920-1353829.png";
      sha256 = "0jyr6i17hsvdjx59m81h43301dcb6gsr62gnzsxs076i3yj7rd25";
    };
  };
}
