{
  config,
  lib,
  pkgs,
  ...
}:

{
  flake.homeModules.direnv =
    { ... }:
    {
      programs.direnv = {
        enable = true;
        nix-direnv.enable = true;
        enableNushellIntegration = true;
        silent = true;
      };
    };
}
