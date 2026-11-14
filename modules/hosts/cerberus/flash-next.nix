{ inputs, ... }:
{
  flake.nixosModules.cerberus =
    { pkgs, ... }:
    let
      gufo = inputs.gufo.packages.${pkgs.stdenv.hostPlatform.system}.release;
      modelDir = "/var/lib/gufo/models/flash-next-q4";
      gpuMemoryLimit = "ttm.pages_limit=29360128";
      serve = inputs.gufo.lib.mkGufoServe {
        inherit gufo;
        provider = "flash-next-q4";
        model = "${modelDir}/UD-Q4_K_XL/Qwen3.8-Flash-Next-UD-Q4_K_XL-00001-of-00004.gguf";
        servedModelName = "qwen3.8-flash-next";
        host = "127.0.0.1";
        port = 8080;
        sessions = 1;
        context = 262144;
        speculative = "mtp";
        mtpModel = "${modelDir}/MTP/mtp-Qwen3.8-Flash-Next-shared-Q8_0.gguf";
        reasoningEffort = "medium";
        temperature = 1.0;
        topP = 0.95;
        topK = 20;
        cacheDisk = "/var/cache/gufo/prompts";
        cacheDiskBytes = 8589934592;
        extraArgs = [
          "--cache-ram-bytes"
          "1073741824"
        ];
      };
    in
    {
      # Raise the shared GPU memory ceiling to 112 GiB; this does not reserve RAM.
      boot.kernelParams = [ gpuMemoryLimit ];

      nix.settings = {
        extra-substituters = [ "https://gufo.cachix.org" ];
        extra-trusted-public-keys = [
          "gufo.cachix.org-1:rfZe3n4lHINgyoACKzs5EthIZmBNvEyCCtufUpth0PE="
        ];
      };

      environment.systemPackages = [ gufo ];

      systemd.services.gufo = {
        description = "Qwen3.8 Flash-Next with MTP";
        wants = [ "network-online.target" ];
        after = [ "network-online.target" ];
        unitConfig.ConditionKernelCommandLine = gpuMemoryLimit;

        environment = {
          HOME = "/var/lib/gufo";
          XDG_CACHE_HOME = "/var/cache/gufo";
          XDG_DATA_HOME = "/var/lib/gufo";
        };

        # Download in the running service so the first boot need not wait for weights.
        script = ''
          ${pkgs.python3Packages.huggingface-hub}/bin/hf download unsloth/Qwen3.8-Flash-Next-GGUF \
            --revision d96201194f103c906994f283f504209dc8d2a10c \
            --include "UD-Q4_K_XL/*" \
            --include "MTP/mtp-Qwen3.8-Flash-Next-shared-Q8_0.gguf" \
            --local-dir ${modelDir}
          exec ${serve}
        '';

        serviceConfig = {
          Type = "exec";
          DynamicUser = true;
          SupplementaryGroups = [
            "video"
            "render"
          ];
          StateDirectory = "gufo";
          CacheDirectory = "gufo";
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
