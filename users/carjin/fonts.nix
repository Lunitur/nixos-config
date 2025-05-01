{ config, pkgs-unstable, ... }:

{
  home.packages = with pkgs-unstable; [
    jetbrains-mono
    noto-fonts
    noto-fonts-emoji
    fira-code
    nerd-fonts.jetbrains-mono
  ];

  fonts.fontconfig.enable = true;
}
