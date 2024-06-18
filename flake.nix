{
  description = "Nixos config flake";

  inputs = {
    nixpkgs-unstable.url = "github:nixos/nixpkgs/master";

    nixpkgs-stable.url = "github:nixos/nixpkgs/nixos-24.05";

    home-manager-stable = {
      url = "github:nix-community/home-manager/release-24.05";
      inputs.nixpkgs.follows = "nixpkgs-stable";
    };

    home-manager-unstable = {
      url = "github:nix-community/home-manager/master";
      inputs.nixpkgs.follows = "nixpkgs-unstable";
    };

    nixvim = {
      url = "github:nix-community/nixvim";
      inputs.nixpkgs.follows = "nixpkgs-stable";
    };

    stylix = {
      url = "github:danth/stylix";
      inputs.nixpkgs.follows = "nixpkgs-unstable";
    };
  };

  outputs = { self, nixpkgs-unstable, nixpkgs-stable, home-manager-stable
    , home-manager-unstable, nixvim, stylix, ... }@inputs:
    let
      pkgs-unstable = import nixpkgs-unstable {
        system = "x86_64-linux";
        config.allowUnfree = true;
      };
      pkgs-stable = import nixpkgs-stable {
        system = "x86_64-linux";
        config.allowUnfree = true;
      };
      modules = import ./modules;
      user-pkgs = import ./pkgs { pkgs = pkgs-stable; };
    in {
      nixosConfigurations.victus = nixpkgs-unstable.lib.nixosSystem {
        specialArgs = {
          inherit pkgs-unstable pkgs-stable modules user-pkgs nixvim stylix;
          home-manager = home-manager-unstable;
        };
        system = "x86_64-linux";
        modules = [
          ./hosts/victus
          ./hosts # defaults
          ./users
          home-manager-unstable.nixosModules.default
          stylix.nixosModules.stylix
          modules.stylix
        ];
      };
      nixosConfigurations.minibook = nixpkgs-unstable.lib.nixosSystem {
        specialArgs = {
          inherit pkgs-unstable pkgs-stable modules user-pkgs nixvim stylix;
          home-manager = home-manager-unstable;
        };
        system = "x86_64-linux";
        modules = [
          ./hosts/minibook
          ./hosts # defaults
          ./users
          home-manager-unstable.nixosModules.default
          stylix.nixosModules.stylix
          modules.stylix
        ];
      };
    };
}
