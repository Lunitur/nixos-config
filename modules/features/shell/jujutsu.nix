{ ... }:
{
  flake.homeModules.jujutsu =
    { ... }:
    {
      programs.jujutsu = {
        enable = true;
        settings = {
          user = {
            email = "karlo.puselj@gmail.com";
            name = "Lunitur";
          };
        };
      };
    };
}
