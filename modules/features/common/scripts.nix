{ ... }:
{
  flake.nixosModules.common-scripts =
    {
      config,
      lib,
      pkgs,
      ...
    }:
    let
      # Import every script package from the repo-level scripts folder.
      # Each file is expected to be a function taking { pkgs } and returning
      # a package (see ../scripts/monitor.nix for the pattern).
      scriptsDir = ../../../scripts;
      scriptFiles = builtins.attrNames (builtins.readDir scriptsDir);
      scriptNixs = builtins.filter (f: lib.hasSuffix ".nix" f) scriptFiles;
      scriptPackages = map (f: import (scriptsDir + "/${f}") { inherit pkgs; }) scriptNixs;
    in
    {
      environment.systemPackages = scriptPackages;
    };
}
