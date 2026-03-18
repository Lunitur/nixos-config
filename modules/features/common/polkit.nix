{ ... }:
{
  flake.nixosModules.polkit =
    { config, lib, ... }:
    {
      security.polkit.enable = true;
    };
}
