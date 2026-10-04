{ ... }:
{
  flake.homeModules.codex =
    {
      config,
      lib,
      pkgs,
      ...
    }:
    {
      programs.codex = {
        enable = true;
        # The desktop NixOS module already installs Codex.
        package = null;
        settings = {
          approvals_reviewer = "user";
          model = "gpt-6.1-sol";
          model_reasoning_effort = "high";
          features.memories = true;
          notice.hide_full_access_warning = true;
          tui = {
            screen_reader_detection_done = true;
            model_availability_nux = {
              "gpt-5.6-sol" = 4;
              "gpt-6-astra" = 4;
              "gpt-6.1-sol" = 1;
            };
          };

          projects =
            lib.genAttrs
              [
                config.home.homeDirectory
                "${config.home.homeDirectory}/nixos"
                "${config.home.homeDirectory}/nixpkgs"
                "${config.home.homeDirectory}/projects/linux-vayu"
                "${config.home.homeDirectory}/math-notes"
                "${config.home.homeDirectory}/.local/state/Heroic/logs/games/hJW6Hij6DG63mC9PdfZLNq_sideload"
                "${config.home.homeDirectory}/Games/Heroic/Prefixes/default/FTL AE"
                "${config.home.homeDirectory}/projects/sts2-analysis"
                "${config.home.homeDirectory}/Nextcloud/skripte"
                "${config.home.homeDirectory}/projects"
                "${config.home.homeDirectory}/projects/julia-mode"
                "${config.home.homeDirectory}/projects/zadaca-strojno"
                "/tmp/luka-typst"
              ]
              (_: {
                trust_level = "trusted";
              });

          mcp_servers.emacs = {
            command = lib.getExe' pkgs.nodejs "npx";
            args = [
              "-y"
              "@keegancsmith/emacs-mcp-server@0.0.1"
            ];
            env_vars = [ "XDG_RUNTIME_DIR" ];
          };
        };
      };
    };
}
