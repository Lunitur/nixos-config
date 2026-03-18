{ ... }:
{
  flake.nixosModules.matrix-server =
    { config, lib, ... }:
    let
      isNano = config.networking.hostName == "nano";
    in
    {
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
      services.nginx.virtualHosts."matrix.example.com" = {
        forceSSL = isNano;
        enableACME = isNano;
        locations."/_matrix" = {
          proxyPass = "http://127.0.0.1:8008";
          proxyWebsockets = true;
        };
      };
      services.nginx.enable = true;
    };
}
