{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.services.sus-membership;
  python = pkgs.python3.withPackages (ps: [
    (ps.toPythonModule (pkgs.maubot.override { encryptionSupport = cfg.requireEncryption; }))
  ]);
  authDir = "/var/lib/sus-membership-auth";
  secretDir = "/var/lib/sus-membership-secrets";
  setup = pkgs.writeShellApplication {
    name = "sus-membership-setup";
    runtimeInputs = [
      pkgs.python3
      pkgs.systemd
    ];
    text = ''
      export SUS_MEMBERSHIP_ROOM=${lib.escapeShellArg cfg.room}
      export SUS_MEMBERSHIP_HOMESERVER=${lib.escapeShellArg cfg.homeserver}
      export SUS_MEMBERSHIP_REGISTRATION_TOKEN_FILE=${lib.escapeShellArg cfg.registrationTokenFile}
      exec python3 ${./setup.py} "$@"
    '';
  };
in
{
  options.services.sus-membership = {
    enable = lib.mkEnableOption "SUS formular i Matrix bot za prijave";
    homeserver = lib.mkOption {
      type = lib.types.str;
      default = "https://matrix.autonomija.net";
    };
    room = lib.mkOption {
      type = lib.types.str;
      default = "#zahtjevi-za-clanstvo:autonomija.net";
    };
    port = lib.mkOption {
      type = lib.types.port;
      default = 29317;
    };
    requireEncryption = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = "Zahtijevaj E2EE i instaliraj kriptografske ovisnosti maubota. Trenutačni libolm Nixpkgs blokira kao nesiguran.";
    };
    registrationTokenFile = lib.mkOption {
      type = lib.types.str;
      default = "/var/lib/tuwunel-autonomija/registration-token";
    };
  };

  config = lib.mkIf cfg.enable {
    assertions = [
      {
        assertion = config.services.sus-grav.enable;
        message = "SUS prijave zahtijevaju services.sus-grav.enable.";
      }
    ];
    environment.systemPackages = [ setup ];
    system.build.sus-membership-setup = setup;
    users.users.sus-membership = {
      isSystemUser = true;
      group = "sus-membership";
    };
    users.groups.sus-membership = { };
    systemd.tmpfiles.rules = [
      "d ${authDir} 0750 root sus-grav -"
      "d ${secretDir} 0700 root root -"
    ];
    systemd.services.sus-membership-token = {
      description = "Tajna za lokalni prijenos SUS prijava";
      wantedBy = [ "multi-user.target" ];
      before = [
        "phpfpm-sus-grav.service"
        "sus-membership.service"
      ];
      serviceConfig = {
        Type = "oneshot";
        RemainAfterExit = true;
        UMask = "0077";
      };
      script = ''
        if [ ! -s ${authDir}/token ]; then
          ${lib.getExe pkgs.openssl} rand -hex 32 > ${authDir}/token.tmp
          chown root:sus-grav ${authDir}/token.tmp
          chmod 0640 ${authDir}/token.tmp
          mv ${authDir}/token.tmp ${authDir}/token
        fi
      '';
    };
    services.phpfpm.pools.sus-grav.phpEnv = {
      SUS_MEMBERSHIP_TOKEN_FILE = "${authDir}/token";
      SUS_MEMBERSHIP_URL = "http://127.0.0.1:${toString cfg.port}";
    };
    systemd.services.phpfpm-sus-grav = {
      requires = [ "sus-membership-token.service" ];
      after = [ "sus-membership-token.service" ];
    };
    systemd.services.sus-membership = {
      description = "SUS prijave za članstvo — maubot";
      wantedBy = [ "multi-user.target" ];
      wants = [
        "network-online.target"
        "tuwunel.service"
      ];
      requires = [ "sus-membership-token.service" ];
      after = [
        "network-online.target"
        "tuwunel.service"
        "sus-membership-token.service"
      ];
      unitConfig.ConditionPathExists = "${secretDir}/bot.json";
      environment = {
        SUS_MEMBERSHIP_PORT = toString cfg.port;
        SUS_MEMBERSHIP_REQUIRE_ENCRYPTION = if cfg.requireEncryption then "1" else "0";
        PYTHONTZPATH = "${pkgs.tzdata}/share/zoneinfo";
      };
      preStart = ''
        ${python}/bin/python ${./runtime.py}
      '';
      serviceConfig = {
        ExecStart = "${python}/bin/python ${./run.py} --config /run/sus-membership/config.yaml --meta ${./.}/maubot.yaml";
        User = "sus-membership";
        Group = "sus-membership";
        WorkingDirectory = "/var/lib/sus-membership";
        StateDirectory = "sus-membership";
        StateDirectoryMode = "0700";
        RuntimeDirectory = "sus-membership";
        RuntimeDirectoryMode = "0700";
        LoadCredential = [
          "bot.json:${secretDir}/bot.json"
          "webhook-token:${authDir}/token"
        ];
        UMask = "0077";
        Restart = "on-failure";
        RestartSec = "10s";
        TimeoutStopSec = 30;
        NoNewPrivileges = true;
        PrivateTmp = true;
        PrivateDevices = true;
        ProtectSystem = "strict";
        ProtectHome = true;
        ProtectKernelTunables = true;
        ProtectKernelModules = true;
        ProtectControlGroups = true;
        RestrictSUIDSGID = true;
        RestrictAddressFamilies = [
          "AF_INET"
          "AF_INET6"
          "AF_UNIX"
        ];
      };
    };
  };
}
