{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.features.services.matrix;
in
{
  options.features.services.matrix.enable = lib.mkEnableOption "Matrix Synapse server";

  config = lib.mkIf cfg.enable {
    services.matrix-synapse = {
      enable = true;
      settings = {
        server_name = "matrix.example.com";
        listeners = [
          {
            port = 8008;
            bind_addresses = [ "127.0.0.1" ];
            type = "http";
            tls = false;
            x_forwarded = true;
            resources = [
              {
                names = [
                  "client"
                  "federation"
                ];
                compress = false;
              }
            ];
          }
        ];
        enable_registration = true;
      };
    };

    services.nginx = {
      enable = true;
      virtualHosts."matrix.example.com" = {
        forceSSL = config.networking.hostName == "nano";
        enableACME = config.networking.hostName == "nano";
        locations."/_matrix" = {
          proxyPass = "http://127.0.0.1:8008";
          proxyWebsockets = true;
        };
      };
    };
  };
}
