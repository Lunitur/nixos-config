{ ... }:
{
  flake.nixosModules.features-desktop-wlr =
    { config, lib, ... }:
    {
      xdg.portal.wlr.enable = true;
    };
}
