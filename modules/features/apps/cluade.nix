{ ... }:
{
  flake.homeModules.claude =
    {
      config,
      lib,
      pkgs,
      ...
    }:
    {
      programs = {
        claude-code = {
          enable = true;
        };
      };

      home.packages = [
        (pkgs.writeShellScriptBin "claude-deepseek" ''
          export ANTHROPIC_BASE_URL="https://api.deepseek.com/anthropic"
          export ANTHROPIC_MODEL="deepseek-v4-flash"
          export ANTHROPIC_DEFAULT_OPUS_MODEL="deepseek-v4-pro[1m]"
          export ANTHROPIC_DEFAULT_SONNET_MODEL="deepseek-v4-pro[1m]"
          export ANTHROPIC_DEFAULT_HAIKU_MODEL="deepseek-v4-flash"
          export CLAUDE_CODE_SUBAGENT_MODEL="deepseek-v4-flash"
          export CLAUDE_CODE_EFFORT_LEVEL="max"
          unset CLAUDE_CODE_OAUTH_TOKEN

          exec ${pkgs.claude-code}/bin/claude "$@"
        '')
        (pkgs.writeShellScriptBin "claude-anthropic" ''
          unset ANTHROPIC_AUTH_TOKEN
          unset ANTHROPIC_BASE_URL
          unset ANTHROPIC_MODEL
          unset ANTHROPIC_DEFAULT_OPUS_MODEL
          unset ANTHROPIC_DEFAULT_SONNET_MODEL
          unset ANTHROPIC_DEFAULT_HAIKU_MODEL
          unset CLAUDE_CODE_SUBAGENT_MODEL
          unset CLAUDE_CODE_EFFORT_LEVEL

          exec ${pkgs.claude-code}/bin/claude "$@"
        '')

      ];
    };

  flake.nixosModules.claude = {
    environment.variables = {
      ANTHROPIC_BASE_URL = "https://api.deepseek.com/anthropic";
      ANTHROPIC_MODEL = "deepseek-v4-flash";
      ANTHROPIC_DEFAULT_OPUS_MODEL = "deepseek-v4-pro[1m]";
      ANTHROPIC_DEFAULT_SONNET_MODEL = "deepseek-v4-pro[1m]";
      ANTHROPIC_DEFAULT_HAIKU_MODEL = "deepseek-v4-flash";
      CLAUDE_CODE_SUBAGENT_MODEL = "deepseek-v4-flash";
      CLAUDE_CODE_EFFORT_LEVEL = "max";
    };

    environment.sessionVariables = {
      ANTHROPIC_BASE_URL = "https://api.deepseek.com/anthropic";
      ANTHROPIC_MODEL = "deepseek-v4-flash";
      ANTHROPIC_DEFAULT_OPUS_MODEL = "deepseek-v4-pro[1m]";
      ANTHROPIC_DEFAULT_SONNET_MODEL = "deepseek-v4-pro[1m]";
      ANTHROPIC_DEFAULT_HAIKU_MODEL = "deepseek-v4-flash";
      CLAUDE_CODE_SUBAGENT_MODEL = "deepseek-v4-flash";
      CLAUDE_CODE_EFFORT_LEVEL = "max";
    };
  };
}
