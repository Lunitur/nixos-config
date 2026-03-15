{
  config,
  lib,
  ...
}:
let
  cfg = config.features.apps.gemini-cli;
in
{
  options.features.apps.gemini-cli.enable = lib.mkEnableOption "Gemini CLI";

  config = lib.mkIf cfg.enable {
    home-manager.users.carjin = {
      programs.gemini-cli = {
        enable = true;
        defaultModel = "gemini-3-pro-preview";
        settings = {
          general = {
            preferredEditor = "hx";
            vimMode = true;
            disableAutoUpdate = true;
            disableUpdateNag = true;
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
          };
          privacy.usageStatisticsEnabled = false;
          experimental = {
            plan = true;
            modelSteering = true;
          };
        };
      };
    };
  };
}