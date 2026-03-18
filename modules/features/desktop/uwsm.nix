{ ... }:
{
  flake.nixosModules.features-desktop-uwsm =
    { config, lib, ... }:
    {
      programs.uwsm.enable = true;
      programs.uwsm.waylandCompositors = lib.mkDefault { };
    };
}
