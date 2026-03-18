{ inputs, ... }:
{
  flake.nixosModules.server = {
    imports = [
      inputs.self.nixosModules.anarhizam-org
      # inputs.self.nixosModules.common-fonts
      inputs.self.nixosModules.features-common-theme-stylix
      inputs.self.nixosModules.headscale
      inputs.self.nixosModules.irc-anarhizam-org
      inputs.self.nixosModules.network-base
      inputs.self.nixosModules.polkit
      inputs.self.nixosModules.syncthing
      inputs.self.nixosModules.tailscale
    ];
  };

  flake.homeModules.server = {
    imports = [
      inputs.self.homeModules.common-dotfiles
      inputs.self.homeModules.common-theme-stylix
      inputs.self.homeModules.gemini-cli
      inputs.self.homeModules.git
      inputs.self.homeModules.helix
      inputs.self.homeModules.jujutsu
      inputs.self.homeModules.ls-colors
      inputs.self.homeModules.nushell
      inputs.self.homeModules.pueue
      inputs.self.homeModules.shell-scripts
      inputs.self.homeModules.ssh
      inputs.self.homeModules.starship
      inputs.self.homeModules.xdg-mime
      inputs.self.homeModules.yazi
      inputs.self.homeModules.zsh
    ];
  };
}
