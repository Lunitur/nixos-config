{ ... }:
{
  flake.homeModules.desktop-conky =
    { ... }:
    {
      services.conky.enable = true;
    };
}
