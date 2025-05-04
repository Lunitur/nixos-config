{
  config,
  pkgs-unstable,
  pkgs,
  ...
}:

{
  # home.packages = with pkgs-unstable; [
  #   jetbrains-mono
  #   noto-fonts
  #   noto-fonts-emoji
  #   fira-code
  #   nerd-fonts.jetbrains-mono
  # ];

  home.packages = with pkgs; [
    jetbrains-mono
    # noto-fonts
    # noto-fonts-emoji
    fira-code
    nerdfonts
  ];

  fonts.fontconfig.enable = true;
}
