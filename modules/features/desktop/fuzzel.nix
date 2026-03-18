{ ... }:
{
  flake.homeModules.fuzzel =
    { ... }:
    {
      programs.fuzzel.enable = true;
      programs.fuzzel.settings = {
        main = {
          prompt = "> ";
          lines = 15;
          width = 40;
          icons-enabled = "yes";
        };
        border = {
          width = 1;
          radius = 5;
        };
      };
    };
}
