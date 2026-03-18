{
  inputs,
  ...
}:
{
  flake.nixosModules.nano = {
    imports = [
      inputs.self.nixosModules.all
      inputs.simple-nixos-mailserver.nixosModule
      inputs.home-manager-stable.nixosModules.default
      inputs.stylix.nixosModules.stylix
      inputs.self.nixosModules.server
      {
        home-manager = {
          users = {
            carjin = {
              imports = [ inputs.self.homeModules.server ];
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