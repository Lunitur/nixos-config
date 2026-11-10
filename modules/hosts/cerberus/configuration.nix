{ inputs, ... }:
{
  flake.nixosConfigurations = inputs.self.lib.mkNixosUnstable "x86_64-linux" "cerberus";

  flake.nixosModules.cerberus = {
    imports = [
      inputs.self.nixosModules.all
      inputs.self.nixosModules.desktop
      inputs.nixos-hardware.nixosModules.common-cpu-amd
      inputs.nixos-hardware.nixosModules.common-cpu-amd-pstate
      inputs.nixos-hardware.nixosModules.common-gpu-amd
      inputs.nixos-hardware.nixosModules.common-pc-laptop
      inputs.nixos-hardware.nixosModules.common-pc-laptop-ssd
      inputs.nixos-hardware.nixosModules.common-hidpi
      inputs.home-manager.nixosModules.default
      inputs.stylix.nixosModules.stylix
      {
        home-manager = {
          extraSpecialArgs = {
            inherit inputs;
            inherit (inputs) self;
          };
          users.carjin = {
            imports = [
              inputs.self.homeModules.desktop
              inputs.self.homeModules.all
            ];
            home.username = "carjin";
            home.homeDirectory = "/home/carjin";
            home.stateVersion = "26.05";
            programs.home-manager.enable = true;
          };

          backupFileExtension = "backup";
          useGlobalPkgs = true;
        };
      }
    ];
  };
}
