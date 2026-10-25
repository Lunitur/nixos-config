{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.services.sus-mail;
  secretDir = "/var/lib/sus-mail-secrets";
  setup = pkgs.writeShellApplication {
    name = "sus-mail-setup";
    runtimeInputs = [
      pkgs.python3
      pkgs.systemd
    ];
    text = ''
      export SUS_MAIL_HOMESERVER=${lib.escapeShellArg cfg.homeserver}
      export SUS_MAIL_ROOM=${lib.escapeShellArg cfg.room}
      export SUS_MAIL_REGISTRATION_TOKEN_FILE=${lib.escapeShellArg cfg.registrationTokenFile}
      exec python3 ${./.}/setup.py "$@"
    '';
  };
in
{
  options.services.sus-mail = {
    enable = lib.mkEnableOption "forwarding new SUS inbox mail to Matrix";
    homeserver = lib.mkOption {
      type = lib.types.str;
      default = "https://matrix.autonomija.net";
    };
    room = lib.mkOption {
      type = lib.types.str;
      default = "#sus-mail:autonomija.net";
    };
    mailboxPath = lib.mkOption {
      type = lib.types.str;
      default = "${config.mailserver.storage.path}/anarhizam.org/sus/mail";
      description = "Maildir inbox to read without changing messages or flags.";
    };
    pollInterval = lib.mkOption {
      type = lib.types.ints.positive;
      default = 15;
    };
    registrationTokenFile = lib.mkOption {
      type = lib.types.str;
      default = "/var/lib/tuwunel-autonomija/registration-token";
    };
  };

  config = lib.mkIf cfg.enable {
    assertions = [
      {
        assertion =
          config.mailserver.enable && builtins.hasAttr "sus@anarhizam.org" config.mailserver.accounts;
        message = "SUS mail forwarding requires the local sus@anarhizam.org mailbox.";
      }
    ];
    environment.systemPackages = [ setup ];
    system.build.sus-mail-setup = setup;
    systemd.services.sus-mail = {
      description = "Forward new SUS inbox mail to Matrix";
      wantedBy = [ "multi-user.target" ];
      wants = [
        "network-online.target"
        "dovecot.service"
        "tuwunel.service"
      ];
      after = [
        "network-online.target"
        "dovecot.service"
        "tuwunel.service"
      ];
      unitConfig.ConditionPathExists = "${secretDir}/bot.json";
      environment = {
        PYTHONDONTWRITEBYTECODE = "1";
        SUS_MAIL_SOURCE = cfg.mailboxPath;
        SUS_MAIL_POLL_INTERVAL = toString cfg.pollInterval;
      };
      serviceConfig = {
        ExecStart = "${pkgs.python3}/bin/python3 ${./.}/forwarder.py";
        User = config.mailserver.storage.owner;
        Group = config.mailserver.storage.group;
        StateDirectory = "sus-mail";
        StateDirectoryMode = "0700";
        WorkingDirectory = "/var/lib/sus-mail";
        LoadCredential = [ "bot.json:${secretDir}/bot.json" ];
        # Expose only this inbox, read-only, outside the hidden mail storage tree.
        BindReadOnlyPaths = [ "${cfg.mailboxPath}:/mailbox" ];
        InaccessiblePaths = [ config.mailserver.storage.path ];
        UMask = "0077";
        Restart = "on-failure";
        RestartSec = "15s";
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
