{ config, inputs, ... }:
{
  configurations.nixos.minibook.module = { pkgs-unstable, ... }: {
    imports = [
      config.flake.modules.nixos.hosts.minibook.default
      config.flake.modules.nixos.hosts.default
      config.flake.modules.nixos.network.default
      config.flake.modules.nixos.desktop-common
      inputs.nixos-hardware.nixosModules.chuwi-minibook-x
      inputs.nixos-hardware.nixosModules.common-cpu-intel
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

    nix.settings = {
      substituters = [ "https://cosmic.cachix.org/" ];
      trusted-public-keys = [ "cosmic.cachix.org-1:Dya9IyXD4xdBehWjrkPv6rtxpmMdRel02smYzA85dPE=" ];
    };
  };
}
