{ config, inputs, ... }:
{
  configurations.nixos.nano = {
    system = "aarch64-linux";
    module = { pkgs-unstable, ... }: {
      imports = [
        config.flake.modules.nixos.hosts.nano.default
        config.flake.modules.nixos.hosts.default
        config.flake.modules.nixos.network.default
        inputs.home-manager-stable.nixosModules.default
        inputs.stylix.nixosModules.stylix
      ];

      home-manager = {
        extraSpecialArgs = {
          inherit pkgs-unstable inputs;
        };
        users.carjin = ../../../users/carjin/home-nano.nix;
        backupFileExtension = "backup";
        useGlobalPkgs = true;
      };
    };
  };
}
