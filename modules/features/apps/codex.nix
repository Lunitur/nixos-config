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
      home.packages = [
        (pkgs.writeShellApplication {
          name = "deepseek-agent";
          runtimeInputs = [
            pkgs.claude-code
            pkgs.gnugrep
          ];
          text = ''
            if [[ "''${1:-}" == --help || "''${1:-}" == -h ]]; then
              cat <<'EOF'
            Usage: deepseek-agent [TASK]

            Run a DeepSeek Flash helper in the current directory with Read, Glob, and Grep.
            Pass one task argument or pipe a task on stdin. Helpers cannot edit files or run
            shell commands, and do not load Claude hooks, plugins, or MCP servers.

            Credentials: DEEPSEEK_API_KEY, then ANTHROPIC_AUTH_TOKEN, then the raw key in
            ''${XDG_CONFIG_HOME:-$HOME/.config}/deepseek/api-key (keep this file private).
            EOF
              exit 0
            fi

            if [[ $# -gt 1 || ( $# -eq 0 && -t 0 ) ]]; then
              echo 'Usage: deepseek-agent [TASK] (or pipe a task on stdin)' >&2
              exit 2
            fi

            deepseek_key="''${DEEPSEEK_API_KEY:-''${ANTHROPIC_AUTH_TOKEN:-}}"
            deepseek_key_file="''${XDG_CONFIG_HOME:-$HOME/.config}/deepseek/api-key"
            if [[ -z "$deepseek_key" && -r "$deepseek_key_file" ]]; then
              deepseek_key=$(< "$deepseek_key_file")
            fi
            if [[ -z "$deepseek_key" ]]; then
              echo "DeepSeek API key missing: set DEEPSEEK_API_KEY or save it in $deepseek_key_file." >&2
              exit 1
            fi

            export ANTHROPIC_API_KEY="$deepseek_key"
            export ANTHROPIC_BASE_URL="https://api.deepseek.com/anthropic"
            export ANTHROPIC_MODEL="deepseek-flash[1m]"
            export ANTHROPIC_DEFAULT_OPUS_MODEL="deepseek-flash[1m]"
            export ANTHROPIC_DEFAULT_SONNET_MODEL="deepseek-flash[1m]"
            export ANTHROPIC_DEFAULT_HAIKU_MODEL="deepseek-flash[1m]"
            export CLAUDE_CODE_SUBAGENT_MODEL="deepseek-flash[1m]"
            export CLAUDE_CODE_EFFORT_LEVEL="high"
            unset ANTHROPIC_AUTH_TOKEN CLAUDE_CODE_OAUTH_TOKEN
            unset CLAUDE_CODE_USE_BEDROCK CLAUDE_CODE_USE_VERTEX CLAUDE_CODE_USE_FOUNDRY

            exec claude --bare --print \
              --model deepseek-flash[1m] \
              --effort high \
              --output-format text \
              --no-session-persistence \
              --permission-mode dontAsk \
              --tools Read,Glob,Grep \
              --allowedTools Read,Glob,Grep \
              --strict-mcp-config \
              --disable-slash-commands \
              --append-system-prompt 'You are a DeepSeek helper working for Codex. Complete only the supplied task. Read applicable AGENTS.md instructions before exploring code. You can read and search files but cannot edit them or run commands. Return concise findings with file paths and line numbers. Distinguish verified facts from suggestions and report any limitations.' \
              -- "$@" 2> >(grep --line-buffered -v '^\[claude-code:unrecognized_model\]' >&2)
          '';
        })
      ];

      home.file.".codex/AGENTS.md".text = ''
        # Coding preferences

        - Write concise, readable code. Avoid unnecessary boilerplate, wrappers, and abstractions.
        - Prefer functional style: small pure functions, immutable data, and composition. Keep side effects at the boundaries.
        - Keep comments minimal. Explain only non-obvious intent, constraints, or tradeoffs; avoid narrating the code.
        - Use idiomatic constructs and clear names. Favor readability over clever one-liners.
        - Default shell on all hosts is Nushell.
        - If you need extra tools use nix to run them.

        # DeepSeek helpers

        - Use `deepseek-agent 'TASK'` for bounded code exploration, analysis, and review when it helps the task. Run it in the relevant project directory.
        - Give each helper a self-contained task with relevant paths, constraints, and the expected result. Helpers have no conversation history and can only read and search files.
        - Independent helper tasks can run concurrently. Keep tasks small and avoid delegating trivial work.
        - Review helper findings yourself; keep edits, tests, and final decisions in Codex.
        - If a helper fails, report the failure and continue directly. Do not retry repeatedly or silently switch providers.
      '';

      programs.codex = {
        enable = false;
        # The desktop NixOS module already installs Codex.
        package = null;
        settings = {
          approvals_reviewer = "user";
          model = "gpt-6.1-sol";
          model_reasoning_effort = "high";
          features.memories = false;
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
                "${config.home.homeDirectory}/Nextcloud/skripte"
                "${config.home.homeDirectory}/projects"
                "${config.home.homeDirectory}/projects/julia-mode"
                "${config.home.homeDirectory}/projects/zadaca-strojno"
                "${config.home.homeDirectory}/projects/nixos-seminar"

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
