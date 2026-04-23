{ ... }:
{
  flake.nixosModules.index-anarhizam-org =
    {
      pkgs,
      config,
      lib,
      ...
    }:
    let
      isNano = config.networking.hostName == "nano";
    in
    {
      services.postgresql = {
        ensureDatabases = [
          "comdex_prod"
        ];
      };
      systemd.services.index-anarhizam-org = lib.mkIf isNano {
        description = "Index.anarhizam.org Phoenix Server (Comdex)";
        after = [
          "network.target"
          "postgresql.service"
        ];
        wantedBy = [ "multi-user.target" ];
        path = [
          pkgs.git
          pkgs.esbuild
          pkgs.tailwindcss_4
        ];
        environment = {
          MIX_ENV = "prod";
          PHX_SERVER = "true";
          PORT = "3001";
          PHX_HOST = "index.anarhizam.org";
          DATABASE_URL = "ecto://comdex@localhost/comdex_prod";
          MIX_HOME = "/home/carjin/comdex/.nix-mix";
          HEX_HOME = "/home/carjin/comdex/.nix-hex";
        };
        serviceConfig = {
          User = "carjin";
          Group = "users";
          WorkingDirectory = "/home/carjin/comdex";
          ExecStart = "${pkgs.elixir_1_19}/bin/mix phx.server";
          Restart = "on-failure";
          RestartSec = "10s";
          EnvironmentFile = "/etc/comdex/secrets.env";
        };
      };
    };
}
