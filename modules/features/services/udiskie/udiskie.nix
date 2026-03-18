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
}
