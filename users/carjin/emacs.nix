{ pkgs, ... }:
{

  programs.emacs = {
    enable = true;
    package = pkgs.emacs-gtk;
  };
  services.emacs.enable = true;

  home.sessionPath = [
    "$HOME/.config/emacs/bin"
  ];

  home.packages = with pkgs; [
    ripgrep
    coreutils
    fd
    clang
  ];
}
