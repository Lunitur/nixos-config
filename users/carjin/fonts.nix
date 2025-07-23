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

  home.packages =
    with pkgs;
    [
      # nerd-fonts.hasklug
      # nerd-fonts.jetbrains-mono
      dejavu_fonts
      jetbrains-mono
      noto-fonts
      noto-fonts-emoji
      fira-code
    ]
    ++ (lib.filter lib.isDerivation (builtins.attrValues nerd-fonts));

  fonts.fontconfig.enable = true;
}
