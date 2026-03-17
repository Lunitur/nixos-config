{
  inputs,
  ...
}:
{
  flake.nixosModules.nano = {
    imports = [
      inputs.self.nixosModules.hosts-default
      inputs.self.nixosModules.allFeatures
      inputs.simple-nixos-mailserver.nixosModule
      inputs.home-manager-stable.nixosModules.default
      inputs.stylix.nixosModules.stylix
      {
        features = {
          hardware.audio.enable = false;
          editors.helix.enable = true;
          shell = {
            zsh.enable = true;
            nushell.enable = true;
            starship.enable = true;
            git.enable = true;
            ssh.enable = true;
            jujutsu.enable = true;
            yazi.enable = true;
          };
          apps.gemini-cli.enable = true;
          services.pueue.enable = true;
          network = {
            headscale.enable = true;
            tailscale.enable = true;
            base.enable = true;
          };
          common = {
            theme.stylix.enable = true;
            dotfiles.enable = true;
            xdg-mime.enable = true;
          };
        };

        home-manager = {
          extraSpecialArgs = {
            inherit inputs;
            inherit (inputs) self;
            pkgs-unstable = import inputs.nixpkgs-unstable {
              system = "aarch64-linux";
              config.allowUnfree = true;
            };
          };
          users = {
            carjin = {
              home.username = "carjin";
              home.homeDirectory = "/home/carjin";
              home.stateVersion = "23.11";
              programs.home-manager.enable = true;
            };
          };

          backupFileExtension = "backup";
          useGlobalPkgs = true;
        };
      }
    ];
  };
}
