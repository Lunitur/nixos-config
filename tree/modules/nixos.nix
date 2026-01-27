{ lib, config, inputs, ... }:
let
  pkgs-unstable = import inputs.nixpkgs-unstable {
    system = "x86_64-linux";
    config.allowUnfree = true;
    overlays = [ inputs.niri.overlays.niri ];
  };
  pkgs-unstable-arm = import inputs.nixpkgs-unstable {
    system = "aarch64-linux";
    config.allowUnfree = true;
    overlays = [ ];
  };
  
  specialArgs = {
    inherit pkgs-unstable pkgs-unstable-arm inputs;
  };
in
{
  options.configurations.nixos = lib.mkOption {
    type = lib.types.lazyAttrsOf (
      lib.types.submodule {
        options.module = lib.mkOption {
          type = lib.types.deferredModule;
        };
        options.system = lib.mkOption {
             type = lib.types.str;
             default = "x86_64-linux";
        };
      }
    );
  };

  config.flake = {
    nixosConfigurations = lib.flip lib.mapAttrs config.configurations.nixos (
      name: { module, system }: inputs.nixpkgs-stable.lib.nixosSystem {
        inherit system specialArgs;
        modules = [ module ];
      }
    );
  };
}
