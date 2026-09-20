{ ... }:
{
  flake.homeModules.atuin =
    { ... }:
    {
      programs.atuin = {
        enable = true;
        enableNushellIntegration = true;
        enableZshIntegration = true;

        settings = {
          filter_mode = "global";
          search_mode = "fuzzy";
          style = "compact";
          inline_height = 20;
          enter_accept = true;
        };
      };
    };
}
