{
  inputs,
  self,
  ...
}:
{
  flake.nixosConfigurations = inputs.self.lib.mkNixos "x86_64-linux" "victus";

  flake.nixosModules.victus =
    {
      config,
      pkgs,
      pkgs-unstable,
      ...
    }:
    {
      imports = [
        inputs.self.nixosModules.all
        inputs.self.nixosModules.desktop
        self.nixosModules.kvmfr
        inputs.nixos-hardware.nixosModules.common-cpu-amd
        inputs.nixos-hardware.nixosModules.common-cpu-amd-pstate
        inputs.nixos-hardware.nixosModules.common-pc-laptop
        inputs.nixos-hardware.nixosModules.common-pc-laptop-ssd
        inputs.nixos-hardware.nixosModules.common-hidpi
        inputs.nix-index-database.nixosModules.default
        inputs.home-manager-stable.nixosModules.default
        inputs.stylix.nixosModules.stylix
        {
          home-manager = {
            # also pass inputs to home-manager modules
            extraSpecialArgs = {
              inherit inputs;
              inherit (inputs) self;
              inherit pkgs-unstable;
            };
            users = {
              carjin = {
                imports = [
                  inputs.self.homeModules.desktop
                  inputs.self.homeModules.all
                ];
                home.username = "carjin";
                home.homeDirectory = "/home/carjin";
                home.stateVersion = "23.11";
                programs.home-manager.enable = true;
              };
            };

            backupFileExtension = "backup";
            useGlobalPkgs = true;
          };
        }
      ];
    };
}
