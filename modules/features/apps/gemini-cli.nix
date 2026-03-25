{ ... }:
{
  flake.homeModules.gemini-cli =
    {
      config,
      lib,
      pkgs-unstable,
      ...
    }:
    {
      programs.gemini-cli = {
        enable = true;
        package = pkgs-unstable.gemini-cli;
        settings = {
          general = {
            enableNotifications = true;
            preferredEditor = "hx";
            vimMode = true;
            disableAutoUpdate = true;
            disableUpdateNag = true;
            previewFeatures = true;
          };
          context = {
            fileName = [
              "AGENTS.md"
              "GEMINI.md"
            ];
          };
          security = {
            auth = {
              selectedType = "oauth-personal";
            };
          };
          ui = {
            theme = "Default";
            footer.hideContextPercentage = false;
            hideBanner = true;
            hideTips = true;
          };
          privacy.usageStatisticsEnabled = false;
          tools = {
            useRipgrep = true;
          };
          experimental = {
            plan = true;
            modelSteering = true;
            skills = true;
            jitContext = true;
          };
        };
      };
    };
}
