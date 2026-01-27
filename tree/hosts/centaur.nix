{ config, inputs, ... }:
{
  configurations.nixos.centaur.module = {
    imports = [
      ../../hosts/centaur
      config.flake.modules.nixos.hosts.default
      config.flake.modules.nixos.network.default
      inputs.home-manager-stable.nixosModules.default
      inputs.stylix.nixosModules.stylix
    ];
  };
}