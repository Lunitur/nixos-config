{
  inputs,
  lib,
  ...
}:
{
  # Helper functions for creating system configurations

  options.flake.lib = lib.mkOption {
    type = lib.types.attrsOf lib.types.unspecified;
    default = { };
  };

  options.flake.homeModules = lib.mkOption {
    type = lib.types.attrsOf lib.types.unspecified;
    default = { };
  };

  options.flake.wrapperModules = lib.mkOption {
    type = lib.types.attrsOf lib.types.unspecified;
    default = { };
  };

  config.flake.lib = {

    # nixosSystem lives on the nixpkgs *flake*, not on a package set's `lib`,
    # so a non-following revision has to come through multiverse's `flakeAt`.
    mkNixos = system: name: {
      ${name} = (inputs.multiverse.multiverse.${system}.flakeAt "26.05").lib.nixosSystem {
        specialArgs = {
          inherit inputs;
          pkgs-unstable = import inputs.nixpkgs-unstable {
            inherit system;
            config.allowUnfree = true;
            config.allowUnfreePredicate = (_: true);
          };
          # for arm
          pkgs-unstable-arm =
            if system == "aarch64-linux" then
              (import inputs.nixpkgs-unstable {
                system = "aarch64-linux";
                config.allowUnfree = true;
                config.allowUnfreePredicate = (_: true);
              })
            else
              null;
        };

        modules = [
          inputs.self.nixosModules.${name}
          {
            nixpkgs.hostPlatform = lib.mkDefault system;
            nixpkgs.config.allowUnfree = true;
            nixpkgs.config.allowUnfreePredicate = (_: true);
          }
        ];
      };
    };

    mkNixosUnstable = system: name: {
      ${name} = inputs.nixpkgs-unstable.lib.nixosSystem {
        specialArgs = {
          inherit inputs;
          pkgs-unstable = import inputs.nixpkgs-unstable {
            inherit system;
            config.allowUnfree = true;
            config.allowUnfreePredicate = (_: true);
          };
          # for arm
          pkgs-unstable-arm =
            if system == "aarch64-linux" then
              (import inputs.nixpkgs-unstable {
                system = "aarch64-linux";
                config.allowUnfree = true;
                config.allowUnfreePredicate = (_: true);
              })
            else
              null;
        };

        modules = [
          inputs.self.nixosModules.${name}
          {
            nixpkgs.hostPlatform = lib.mkDefault system;
            nixpkgs.config.allowUnfree = true;
            nixpkgs.config.allowUnfreePredicate = (_: true);
          }
        ];
      };
    };

  };
}
