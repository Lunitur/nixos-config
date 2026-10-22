{ ... }:
{
  flake.homeModules.atuin =
    { ... }:
    {
      programs.atuin = {
        enable = true;
        enableNushellIntegration = true;
        enableZshIntegration = true;
        daemon.enable = true;

        settings = {
          auto_sync = true;
          sync_address = "https://anarhizam.org/atuin";
          sync_frequency = "1m";
          daemon.sync_frequency = 60;

          filter_mode = "global";
          search_mode = "fuzzy";
          style = "compact";
          inline_height = 20;
          enter_accept = true;
        };
      };
    };
}
