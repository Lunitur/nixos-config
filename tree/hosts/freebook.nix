{ config, inputs, ... }:
{
  configurations.nixos.freebook.module = {
    imports = [
      ../../hosts/freebook
      config.flake.modules.nixos.hosts.default
      config.flake.modules.nixos.network.default
      inputs.nixos-hardware.nixosModules.common-cpu-intel
      inputs.nixos-hardware.nixosModules.common-pc-laptop
      inputs.nixos-hardware.nixosModules.common-pc-laptop-ssd
      inputs.nixos-hardware.nixosModules.common-hidpi
      inputs.home-manager-stable.nixosModules.default
      inputs.stylix.nixosModules.stylix
    ];
  };
}