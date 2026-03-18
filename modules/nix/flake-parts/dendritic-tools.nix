{
  inputs,
  ...
}:
{
  # setup of tools for dendritic pattern

  # Simplify Nix Flakes with the module system
  # https://github.com/hercules-ci/flake-parts

  # Import all nix files in a directory tree.
  # https://github.com/vic/import-tree

  imports = [
  ];

  # set flake.systems
  systems = [
    "x86_64-linux"
    "aarch64-linux"
  ];

  perSystem = { pkgs, system, ... }: {
    _module.args.pkgs = import inputs.nixpkgs {
      inherit system;
      config.allowUnfree = true;
    };
    _module.args.pkgs-unstable = import inputs.nixpkgs-unstable {
      inherit system;
      config.allowUnfree = true;
    };
  };
}


  