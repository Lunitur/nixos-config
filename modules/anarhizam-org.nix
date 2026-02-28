{
  pkgs,
  config,
  lib,
  ...
}:

{
  services.postgresql = {
    enable = true;
    package = pkgs.postgresql_16;

    ensureDatabases = [
      "anarhizam-org"
      "anarhizam_dev"
      "anarhizam_test"
    ];

    ensureUsers = [
      {
        name = "anarhizam-org";
        ensureDBOwnership = true;
      }
    ];

    # Post-startup script to ensure correct ownership and permissions for all databases
    authentication = pkgs.lib.mkForce ''
      # TYPE  DATABASE        USER            ADDRESS                 METHOD
      local   all             all                                     trust
      host    all             all             127.0.0.1/32            trust
      host    all             all             ::1/128                 trust
    '';
  };

  systemd.services.anarhizam-org = lib.mkIf (config.networking.hostName == "nano") {
    description = "Anarhizam.org Phoenix Server";
    after = [
      "network.target"
      "postgresql.service"
    ];
    wantedBy = [ "multi-user.target" ];

    path = [ pkgs.git ];

    environment = {
      MIX_ENV = "prod";
      PHX_SERVER = "true";
      PORT = "3000";
      PHX_HOST = "anarhizam.org";
      DATABASE_URL = "ecto://anarhizam-org@localhost/anarhizam-org";
      MIX_HOME = "/home/carjin/blog-anarhizam-org/.nix-mix";
      HEX_HOME = "/home/carjin/blog-anarhizam-org/.nix-hex";
    };

    serviceConfig = {
      User = "carjin";
      Group = "users";
      WorkingDirectory = "/home/carjin/blog-anarhizam-org";
      ExecStart = "${pkgs.elixir_1_19}/bin/mix phx.server";
      Restart = "on-failure";
      RestartSec = "10s";
      EnvironmentFile = "/etc/anarhizam-org/secrets.env";
    };
  };
}
