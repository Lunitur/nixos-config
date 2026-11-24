{ inputs, ... }:
{
  flake.nixosModules.cerberus =
    { lib, pkgs, ... }:
    let
      gufo = inputs.gufo-inkling.packages.${pkgs.stdenv.hostPlatform.system}.default;
      hf = "${pkgs.python3Packages.huggingface-hub}/bin/hf";
      model = "inkling-2-mini";
      weights = "Inkling-2-Mini-UD-Q4_K_XL.gguf";
      projector = "mmproj-Inkling-2-Mini-Q8_0.gguf";
      context = "262144";
      host = "127.0.0.1";
      port = "8081";
      baseUrl = "http://${host}:${port}";
    in
    {
      environment.systemPackages = [
        (pkgs.writeShellScriptBin "codex-ink" ''
          exec ${lib.getExe pkgs.codex} --no-daemon --model ${model} \
            -c 'model_provider="gufo"' \
            -c 'model_providers.gufo={name="Gufo",base_url="${baseUrl}/v1",wire_api="responses"}' \
            -c 'model_context_window=${context}' \
            -c 'model_reasoning_effort="none"' \
            -c 'web_search="disabled"' "$@"
        '')
        (pkgs.writeShellScriptBin "claude-ink" ''
          unset ANTHROPIC_API_KEY CLAUDE_CODE_OAUTH_TOKEN
          export ANTHROPIC_AUTH_TOKEN=local
          export ANTHROPIC_BASE_URL="${baseUrl}"
          export ANTHROPIC_MODEL="${model}"
          export ANTHROPIC_DEFAULT_OPUS_MODEL="${model}"
          export ANTHROPIC_DEFAULT_SONNET_MODEL="${model}"
          export ANTHROPIC_DEFAULT_HAIKU_MODEL="${model}"
          export CLAUDE_CODE_SUBAGENT_MODEL="${model}"
          export CLAUDE_CODE_MAX_CONTEXT_TOKENS="${context}"
          export CLAUDE_CODE_DISABLE_NONESSENTIAL_TRAFFIC=1
          exec ${lib.getExe pkgs.claude-code} "$@"
        '')
      ];

      systemd.services.gufo-inkling2 = {
        description = "Inkling 2 Mini";
        wantedBy = [ "multi-user.target" ];
        wants = [ "network-online.target" ];
        # Both models together exceed the shared GPU memory limit.
        conflicts = [ "gufo.service" ];
        after = [
          "gufo.service"
          "network-online.target"
        ];

        script = ''
          export HOME="$STATE_DIRECTORY" XDG_CACHE_HOME="$CACHE_DIRECTORY"
          model_dir="$STATE_DIRECTORY/models"
          ${hf} download unsloth/Inkling-2-Mini-GGUF ${weights} \
            --revision 19bf97a66719d0165f6f8082a9d59581912a3863 --local-dir "$model_dir"
          ${hf} download ggml-org/Inkling-2-Mini-GGUF ${projector} \
            --revision e8a2cecf0e78914f07cc27b9be711a9b2c7561d9 --local-dir "$model_dir"
          exec ${gufo}/bin/gufo serve llm \
            --model "$model_dir/${weights}" --mmproj "$model_dir/${projector}" \
            --served-model-name ${model} --context ${context} --sessions 1 \
            --cache-ram-bytes 1073741824 --host ${host} --port ${port}
        '';

        serviceConfig = {
          Type = "exec";
          DynamicUser = true;
          SupplementaryGroups = [
            "video"
            "render"
          ];
          StateDirectory = "gufo-inkling2";
          CacheDirectory = "gufo-inkling2";
          LimitMEMLOCK = "infinity";
          Restart = "on-failure";
          RestartSec = 15;
          PrivateTmp = true;
          ProtectHome = true;
          ProtectSystem = "strict";
          NoNewPrivileges = true;
        };
      };
    };
}
