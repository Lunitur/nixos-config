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

    mkNixos = system: name: {
      ${name} = inputs.nixpkgs-stable.lib.nixosSystem {
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
          # other inputs that were in specialArgs
          nixvim = inputs.nixvim;
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
