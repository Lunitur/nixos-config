{ config, inputs, ... }:
{
  configurations.nixos.nano = {
    system = "aarch64-linux";
    module = { pkgs-unstable, ... }: {
      imports = [
        ../../hosts/nano
        ../../users/carjin/user.nix
        config.flake.modules.nixos.network.default
        inputs.simple-nixos-mailserver.nixosModule
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