{
  inputs,
  ...
}:
{
  flake.nixosConfigurations = inputs.self.lib.mkNixosUnstable "x86_64-linux" "minibook";

  flake.nixosModules.minibook =
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
        inputs.nixos-hardware.nixosModules.chuwi-minibook-x
        inputs.nixos-hardware.nixosModules.common-cpu-intel
        inputs.nixos-hardware.nixosModules.common-pc-laptop
        inputs.nixos-hardware.nixosModules.common-pc-laptop-ssd
        inputs.nixos-hardware.nixosModules.common-hidpi
        inputs.home-manager.nixosModules.default
        inputs.stylix.nixosModules.stylix
        inputs.nix-index-database.nixosModules.default
        {
          home-manager = {
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

          nix.settings = {
            substituters = [ "https://cosmic.cachix.org/" ];
            trusted-public-keys = [ "cosmic.cachix.org-1:Dya9IyXD4xdBehWjrkPv6rtxpmMdRel02smYzA85dPE=" ];
          };
        }
      ];
    };
}
