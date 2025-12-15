{
  pkgs-unstable,
  modules,
  pkgs,
  lib,
  ...
}:
{

  imports = [
    ./dotfiles.nix
    ./yazi.nix
    ./mpv.nix
    ./jujutsu.nix
    # ./distrobox.nix
    ./pueue.nix
    ./foot.nix
    ./zathura.nix
    # ./conky.nix
    ./helix.nix
    ./git.nix
    ./zsh.nix
    ./udiskie.nix
    ./swaync.nix
    ./starship.nix
    ./rofi.nix
    ./kitty.nix
    ./fonts.nix
    # ./latex.nix
    ./packages.nix
    # ./hyprland
    ./waybar
    ./nushell
    ./fuzzel.nix
    ./firefox.nix
    ./emacs.nix
    ./niri
    ./typst.nix
    # ./stylix
    # ./theme
  ];

  home.username = "carjin";
  home.homeDirectory = "/home/carjin";

  home.stateVersion = "23.11";

  systemd.user.services.hyprpaper = {
    Unit = {
      After = [ "wayland-session-waitenv.service" ];
    };
  };

  systemd.user.services.hypridle = {
    Unit = {
      After = [ "wayland-session-waitenv.service" ];
    };
  };

  home.sessionVariables = {
    EDITOR = "hx";
  };

  programs.home-manager.enable = true;

  dconf.enable = true;

  stylix = {
    iconTheme = {
      enable = true;
      package = pkgs.papirus-icon-theme;
      dark = "Papirus-Dark";
      light = "Papirus-Light";
    };
    targets = {
      waybar.enable = false;
      hyprland.enable = false;
      hyprlock.enable = false;
      vscode.enable = false;
      wofi.enable = false;
    };
  };

  dconf.settings = {
    "org/virt-manager/virt-manager/connections" = {
      autoconnect = [ "qemu:///system" ];
      uris = [ "qemu:///system" ];
    }; # fix ui virt-manager bug
  };

}
