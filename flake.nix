{
  description = "Nixos config flake";

  inputs = {
    firefox-gnome-theme = {
      url = "github:rafaelmardojai/firefox-gnome-theme";
      flake = false;
    };

    nixpkgs-unstable.url = "github:nixos/nixpkgs/master";
    # nixpkgs-unstable.url = "github:Lunitur/nixpkgs/master";

    umu.url = "github:Open-Wine-Components/umu-launcher?dir=packaging/nix";

    nixpkgs-stable.url = "github:nixos/nixpkgs/nixos-25.11";
    # nixpkgs-stable.url = "path:/home/carjin/nixpkgs";

    nixos-hardware.url = "github:NixOS/nixos-hardware/master";

    home-manager-stable = {
      url = "github:nix-community/home-manager/release-25.11";
      inputs.nixpkgs.follows = "nixpkgs-stable";
    };

    stylix = {
      url = "github:danth/stylix/release-25.11";
      inputs.nixpkgs.follows = "nixpkgs-stable";
    };

    simple-nixos-mailserver.url = "gitlab:simple-nixos-mailserver/nixos-mailserver/nixos-25.11";

    niri = {
      url = "github:sodiboo/niri-flake";
      inputs.nixpkgs.follows = "nixpkgs-stable";
    };
  };

  outputs =
    {
      self,
      nixpkgs-unstable,
      nixpkgs-stable,
      nixos-hardware,
      home-manager-stable,
      simple-nixos-mailserver,
      stylix,
      niri,
      ...
    }@inputs:
    let
      pkgs-unstable = import nixpkgs-unstable {
        system = "x86_64-linux";
        config.allowUnfree = true;
        overlays = [ niri.overlays.niri ];
      };
      pkgs-unstable-arm = import nixpkgs-unstable {
        system = "aarch64-linux";
        config.allowUnfree = true;
        overlays = [ ];
      };
      specialArgs = {
        inherit
          pkgs-unstable
          pkgs-unstable-arm
          inputs
          ;
      };
    in
    {
      nixosConfigurations.victus = nixpkgs-stable.lib.nixosSystem {
        inherit specialArgs;
        system = "x86_64-linux";
        modules = [
          ./hosts/victus
          ./hosts # defaults
          ./network
          ./modules/desktop-common.nix
          nixos-hardware.nixosModules.common-cpu-amd
          nixos-hardware.nixosModules.common-cpu-amd-pstate
          nixos-hardware.nixosModules.common-pc-laptop
          nixos-hardware.nixosModules.common-pc-laptop-ssd
          nixos-hardware.nixosModules.common-hidpi
          home-manager-stable.nixosModules.default
          stylix.nixosModules.stylix
          niri.nixosModules.niri
          {
            home-manager = {
              # also pass inputs to home-manager modules
              extraSpecialArgs = {
                inherit pkgs-unstable inputs;
              };
              users = {
                carjin = ./users/carjin/home.nix;
              };

              backupFileExtension = "backup";
              useGlobalPkgs = true;
            };
          } # modules.cosmic
        ];
      };
      nixosConfigurations.centaur = nixpkgs-stable.lib.nixosSystem {
        inherit specialArgs;
        system = "x86_64-linux";
        modules = [
          ./hosts/centaur
          ./hosts # defaults
          ./network
          home-manager-stable.nixosModules.default
          stylix.nixosModules.stylix
          #          modules.cosmic
        ];
      };
      nixosConfigurations.minibook = nixpkgs-stable.lib.nixosSystem {
        inherit specialArgs;
        system = "x86_64-linux";
        modules = [
          ./hosts/minibook
          ./hosts # defaults
          ./network
          ./modules/desktop-common.nix
          nixos-hardware.nixosModules.chuwi-minibook-x
          nixos-hardware.nixosModules.common-cpu-intel
          nixos-hardware.nixosModules.common-pc-laptop
          nixos-hardware.nixosModules.common-pc-laptop-ssd
          nixos-hardware.nixosModules.common-hidpi
          home-manager-stable.nixosModules.default
          stylix.nixosModules.stylix
          niri.nixosModules.niri
          {
            home-manager = {
              extraSpecialArgs = {
                inherit pkgs-unstable inputs;
              };
              users = {
                carjin = ./users/carjin/home.nix;
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
      nixosConfigurations.freebook = nixpkgs-stable.lib.nixosSystem {
        inherit specialArgs;
        system = "x86_64-linux";
        modules = [
          ./hosts/freebook
          ./hosts # defaults
          ./network
          nixos-hardware.nixosModules.common-cpu-intel
          nixos-hardware.nixosModules.common-pc-laptop
          nixos-hardware.nixosModules.common-pc-laptop-ssd
          nixos-hardware.nixosModules.common-hidpi
          home-manager-stable.nixosModules.default
          stylix.nixosModules.stylix
        ];
      };
      nixosConfigurations.corebook = nixpkgs-stable.lib.nixosSystem {
        inherit specialArgs;
        system = "x86_64-linux";
        modules = [
          ./hosts/corebook
          ./hosts # defaults
          ./network
          ./modules/desktop-common.nix
          nixos-hardware.nixosModules.common-cpu-intel
          nixos-hardware.nixosModules.common-pc-laptop
          nixos-hardware.nixosModules.common-pc-laptop-ssd
          nixos-hardware.nixosModules.common-hidpi
          home-manager-stable.nixosModules.default
          stylix.nixosModules.stylix
          niri.nixosModules.niri
          {
            home-manager = {
              extraSpecialArgs = {
                inherit pkgs-unstable inputs;
              };
              users = {
                carjin = ./users/carjin/home.nix;
              };

              backupFileExtension = "backup";
              useGlobalPkgs = true;
            };

            nix.settings = {
              substituters = [ "https://cosmic.cachix.org/" ];
              trusted-public-keys = [ "cosmic.cachix.org-1:Dya9IyXD4xdBehWjrkPv6rtxpmMdRel02smYzA85dPE=" ];
            };

          }
          # nixos-cosmic.nixosModules.default
        ];
      };
      nixosConfigurations.nano = nixpkgs-stable.lib.nixosSystem {
        inherit specialArgs;
        system = "aarch64-linux";
        modules = [
          ./hosts/nano
          ./users/carjin/user.nix
          ./network
          simple-nixos-mailserver.nixosModule
          stylix.nixosModules.stylix
        ];
      };
    };
}
