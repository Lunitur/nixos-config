{ ... }:
{
  flake.homeModules.gemini-cli =
    {
      config,
      lib,
      ...
    }:
    {
      programs.gemini-cli = {
        enable = true;
        settings = {
          general = {
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
          };
          privacy.usageStatisticsEnabled = false;
          experimental = {
            plan = true;
            modelSteering = true;
            skills = true;
          };
        };
      };
    };
}
