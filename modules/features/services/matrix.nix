{ ... }:
{
  flake.nixosModules.matrix-server =
    {
      config,
      lib,
      pkgs,
      ...
    }:
    let
      isNano = config.networking.hostName == "nano";

      # Homeserver name: the domain in user IDs (@you:<serverName>).
      serverName = if isNano then "anarhizam.org" else "matrix.localhost";

      # Host that actually serves the API, and the delegation target for
      # serverName. Clients and federating servers resolve serverName, read
      # /.well-known/matrix/* there, and get pointed back here.
      matrixHost = if isNano then "matrix.anarhizam.org" else "matrix.localhost";

      clientUrl = "${if isNano then "https" else "http"}://${matrixHost}";

      wellKnownClient = ''
        default_type application/json;
        return 200 '{"m.homeserver":{"base_url":"${clientUrl}"}}';
      '';

      wellKnownServer = ''
        default_type application/json;
        return 200 '{"m.server":"${matrixHost}:443"}';
      '';
    in
    {
      services.matrix-tuwunel = {
        enable = true;
        settings.global = {
          server_name = serverName;
          address = [ "127.0.0.1" ];
          port = [ 8008 ];
          allow_federation = isNano;
          allow_registration = true;
          registration_token_file = "/var/lib/tuwunel/registration-token";
        };
      };

      # Invite token, generated once and kept out of the nix store.
      # First account to register becomes the server admin.
      systemd.services.tuwunel.preStart = ''
        if [ ! -s /var/lib/tuwunel/registration-token ]; then
          ${lib.getExe pkgs.openssl} rand -hex 32 > /var/lib/tuwunel/registration-token
          chmod 600 /var/lib/tuwunel/registration-token
        fi
      '';

      services.nginx = {
        enable = true;
        virtualHosts = {
          ${matrixHost} = {
            forceSSL = isNano;
            enableACME = isNano;
            extraConfig = ''
              client_max_body_size 20m;
            '';
            locations = {
              "/_matrix" = {
                proxyPass = "http://127.0.0.1:8008";
                proxyWebsockets = true;
                recommendedProxySettings = true;
              };
              "= /.well-known/matrix/client" = {
                extraConfig = wellKnownClient;
              };
            };
          };
        }
        // lib.optionalAttrs (isNano && serverName != matrixHost) {
          # Delegation: serverName is served by matrixHost. The vhost itself
          # (and its cert) is declared in the host config; only the two
          # well-known files are added here. No 8448 listener, so federation
          # is delegated to 443.
          ${serverName}.locations = {
            "= /.well-known/matrix/client" = {
              extraConfig = wellKnownClient;
            };
            "= /.well-known/matrix/server" = {
              extraConfig = wellKnownServer;
            };
          };
        };
      };

      # Loopback-only name, so the throwaway instance is reachable locally.
      networking.hosts = lib.mkIf (!isNano) {
        "127.0.0.1" = [ serverName ];
      };
    };
}
