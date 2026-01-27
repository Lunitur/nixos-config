{ config, inputs, ... }:
{
  configurations.nixos.victus.module = { pkgs-unstable, ... }: {
    imports = [
      config.flake.modules.nixos.hosts.victus.default
      config.flake.modules.nixos.hosts.default
      config.flake.modules.nixos.network.default
      config.flake.modules.nixos.desktop-common
      inputs.nixos-hardware.nixosModules.common-cpu-amd
      inputs.nixos-hardware.nixosModules.common-cpu-amd-pstate
      inputs.nixos-hardware.nixosModules.common-pc-laptop
      inputs.nixos-hardware.nixosModules.common-pc-laptop-ssd
      inputs.nixos-hardware.nixosModules.common-hidpi
      inputs.home-manager-stable.nixosModules.default
      inputs.stylix.nixosModules.stylix
      inputs.niri.nixosModules.niri
    ];

    home-manager = {
      extraSpecialArgs = {
        inherit pkgs-unstable inputs;
      };
      users.carjin = ../../../users/carjin/home.nix;
      backupFileExtension = "backup";
      useGlobalPkgs = true;
    };
  };
}