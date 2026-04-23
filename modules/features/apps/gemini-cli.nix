{ inputs, self, ... }:
{
  flake.wrapperModules.gemini-cli =
    {
      config,
      lib,
      pkgs,
      ...
    }:
    let
      inherit (lib) mkOption types;
    in
    {
      options.gemini-cli = {
        settings = mkOption {
          type = types.attrs;
          default = { };
          description = "Settings for gemini-cli, written to settings.json";
        };
      };

      config = {
        # Package to be wrapped
        package = lib.mkDefault pkgs.gemini-cli;

        # These options are from makeWrapper module
        env.GEMINI_CLI_SYSTEM_SETTINGS_PATH = lib.mkIf (config.gemini-cli.settings != { }) (
          pkgs.writeText "gemini-settings.json" (builtins.toJSON config.gemini-cli.settings)
        );
      };
    };

  perSystem =
    { pkgs, lib, ... }:
    let
      # Use unstable for the latest gemini-cli features
      pkgs-unstable = inputs.nixpkgs-unstable.legacyPackages.${pkgs.stdenv.hostPlatform.system};
    in
    {
      packages.gemini-cli = inputs.wrapper-modules.lib.evalPackage {
        inherit pkgs;
        imports = [
          inputs.wrapper-modules.lib.modules.makeWrapper
          self.wrapperModules.gemini-cli
          {
            # Default settings for the project
            gemini-cli.settings = {
              general = {
                enableNotifications = true;
                preferredEditor = "hx";
                vimMode = true;
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
                modelSteering = true;
                skills = true;
                jitContext = true;
              };
            };
          }
        ];
      };

      packages.gemini-cli-pro = inputs.wrapper-modules.lib.evalPackage {
        inherit pkgs;
        imports = [
          inputs.wrapper-modules.lib.modules.makeWrapper
          self.wrapperModules.gemini-cli
          {
            package = pkgs-unstable.gemini-cli.overrideAttrs (old: {
              src = inputs.gemini-cli-src;
              npmDeps = pkgs.fetchNpmDeps {
                src = inputs.gemini-cli-src;
                hash = "sha256-uSFeXNLbb3NPoSsJUUOnoTlwxFChoTARi2vBT3ms3iY=";
              };
            });

            binName = "gemini-pro";

            # Default settings for the project
            gemini-cli.settings = {
              general = {
                enableNotifications = true;
                preferredEditor = "hx";
                vimMode = true;
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
                modelSteering = true;
                skills = true;
                jitContext = true;
              };
            };
          }
        ];
      };
    };

  flake.homeModules.gemini-cli =
    { pkgs, ... }:
    {
      home.packages = [
        self.packages.${pkgs.stdenv.hostPlatform.system}.gemini-cli
        self.packages.${pkgs.stdenv.hostPlatform.system}.gemini-cli-pro
      ];
    };
}
