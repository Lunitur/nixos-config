{
  inputs,
  ...
}:
{
  flake.modules.nixos.corebook = {
    imports = [
      inputs.self.modules.nixos.corebook-base
      inputs.self.modules.nixos.hosts-default
      inputs.self.modules.nixos.allFeatures
      inputs.nixos-hardware.nixosModules.common-cpu-intel
      inputs.nixos-hardware.nixosModules.common-pc-laptop
      inputs.nixos-hardware.nixosModules.common-pc-laptop-ssd
      inputs.nixos-hardware.nixosModules.common-hidpi
      inputs.home-manager-stable.nixosModules.default
      inputs.stylix.nixosModules.stylix
      inputs.niri.nixosModules.niri
      inputs.nix-index-database.nixosModules.default
      {
        features = {
          desktop = {
            niri.enable = true;
            waybar.enable = true;
            foot.enable = true;
            fuzzel.enable = true;
          };
          editors.helix.enable = true;
          shell = {
            zsh.enable = true;
            nushell.enable = true;
            starship.enable = true;
            git.enable = true;
          };
          apps.firefox.enable = true;
          network.base.enable = true;
          common = {
            theme.stylix.enable = true;
            dotfiles.enable = true;
            fonts.enable = true;
            packages.enable = true;
          };
        };

        home-manager = {
          extraSpecialArgs = {
            inherit inputs;
            inherit (inputs) self;
            pkgs-unstable = import inputs.nixpkgs-unstable {
              system = "x86_64-linux";
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

        nix.settings = {
          substituters = [ "https://cosmic.cachix.org/" ];
          trusted-public-keys = [ "cosmic.cachix.org-1:Dya9IyXD4xdBehWjrkPv6rtxpmMdRel02smYzA85dPE=" ];
        };
      }
    ];
  };
}