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

      serverName = if isNano then "matrix.anarhizam.org" else "matrix.localhost";
      clientUrl = "${if isNano then "https" else "http"}://${serverName}";
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
        virtualHosts.${serverName} = {
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
              extraConfig = ''
                default_type application/json;
                return 200 '{"m.homeserver":{"base_url":"${clientUrl}"}}';
              '';
            };
          }
          // lib.optionalAttrs isNano {
            # No 8448 listener here, so delegate federation to 443.
            "= /.well-known/matrix/server" = {
              extraConfig = ''
                default_type application/json;
                return 200 '{"m.server":"matrix.anarhizam.org:443"}';
              '';
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
