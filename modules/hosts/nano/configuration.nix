{
  inputs,
  ...
}:
{
  flake.nixosConfigurations = inputs.self.lib.mkNixos "aarch64-linux" "nano";

  flake.nixosModules.nano =
    { pkgs-unstable, ... }:
    {
      imports = [
        inputs.self.nixosModules.all
        inputs.simple-nixos-mailserver.nixosModule
        inputs.home-manager-stable.nixosModules.default
        inputs.stylix.nixosModules.stylix
        inputs.self.nixosModules.server
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
                  inputs.self.homeModules.server
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
