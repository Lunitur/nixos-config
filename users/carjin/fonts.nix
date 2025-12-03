{
  config,
  pkgs-unstable,
  pkgs,
  ...
}:

{

  home.packages =
    with pkgs;
    [
      # nerd-fonts.hasklug
      # nerd-fonts.jetbrains-mono
      dejavu_fonts
      jetbrains-mono
      noto-fonts
      noto-fonts-color-emoji
      fira-code
      source-code-pro
      nanum-gothic-coding
    ]
    ++ (lib.filter lib.isDerivation (builtins.attrValues nerd-fonts));

  fonts.fontconfig.enable = true;
}
