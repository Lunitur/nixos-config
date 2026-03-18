{ ... }:
{
  flake.homeModules.desktop-mako =
    { ... }:
    {
      services.mako = {
        enable = true;
        anchor = "bottom-right";
        width = 350;
        margin = "0,20,20";
        borderSize = 1;
        borderRadius = 5;
        defaultTimeout = 10000;
        groupBy = "summary";
        icons = true;
      };
    };
}
