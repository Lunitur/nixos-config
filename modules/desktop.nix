{ inputs, pkgs, ... }:
{
  flake.nixosModules.desktop = {
    imports = [
      inputs.self.nixosModules.anarhizam-org
      inputs.self.nixosModules.avahi
      inputs.self.nixosModules.common-fonts
      inputs.self.nixosModules.features-common-theme-stylix
      # inputs.self.nixosModules.features-desktop-uwsm
      # inputs.self.nixosModules.features-desktop-wlr
      inputs.self.nixosModules.hardware-audio
      inputs.self.nixosModules.hardware-ram
      inputs.self.nixosModules.hardware-usb-tethering
      # inputs.self.nixosModules.headscale
      inputs.self.nixosModules.irc-anarhizam-org
      inputs.self.nixosModules.jupyter
      # inputs.self.nixosModules.kmonad
      inputs.self.nixosModules.moonlight
      inputs.self.nixosModules.network-base
      # inputs.self.nixosModules.nix-ld
      inputs.self.nixosModules.polkit
      inputs.self.nixosModules.spotify
      inputs.self.nixosModules.syncthing
      inputs.self.nixosModules.tailscale
    ];
    nixpkgs.overlays = [
      inputs.self.overlays.brother
    ];

    environment.packages = with pkgs; [
      gvfs
    ];
  };

  flake.homeModules.desktop = {
    imports = [
      inputs.self.homeModules.common-dotfiles
      inputs.self.homeModules.common-fonts
      inputs.self.homeModules.common-theme-stylix
      inputs.self.homeModules.desktop-niri
      inputs.self.homeModules.desktop-packages
      inputs.self.homeModules.desktop-waybar
      # inputs.self.homeModules.distrobox
      inputs.self.homeModules.doom-emacs
      inputs.self.homeModules.firefox
      inputs.self.homeModules.foot
      inputs.self.homeModules.fuzzel
      inputs.self.homeModules.gemini-cli
      inputs.self.homeModules.git
      inputs.self.homeModules.helix
      inputs.self.homeModules.jujutsu
      inputs.self.homeModules.kitty
      # inputs.self.homeModules.latex
      inputs.self.homeModules.ls-colors
      inputs.self.homeModules.mpv
      # inputs.self.homeModules.nixvim
      inputs.self.homeModules.nushell
      inputs.self.homeModules.pueue
      inputs.self.homeModules.services-udiskie
      inputs.self.homeModules.shell-scripts
      inputs.self.homeModules.ssh
      inputs.self.homeModules.starship
      inputs.self.homeModules.swaync
      inputs.self.homeModules.typst
      inputs.self.homeModules.xdg-mime
      inputs.self.homeModules.yazi
      inputs.self.homeModules.zathura
      inputs.self.homeModules.zsh
    ];
  };
}
