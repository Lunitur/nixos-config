{ ... }:
{
  flake.homeModules.services-udiskie =
    { ... }:
    {
      services.udiskie = {
        enable = true;
        automount = true;
      };
    };

  flake.nixosModules.services-udiskie =
    { ... }:
    {
      # udiskie talks to the udisks2 D-Bus daemon; without it udiskie exits 1.
      services.udisks2.enable = true;
    };
}
