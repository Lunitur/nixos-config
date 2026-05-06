{ ... }:
{
  flake.homeModules.claude =
    {
      config,
      lib,
      pkgs,
      ...
    }:
    {
      programs = {
        claude-code = {
          enable = true;
        };
      };
    };
}
