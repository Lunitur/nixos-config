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
      # Homeserver name: the domain in user IDs (@you:<serverName>).
      serverName = "autonomija.net";

      # Host that actually serves the API, and the delegation target for
      # serverName. Clients and federating servers resolve serverName, read
      # /.well-known/matrix/* there, and get pointed back here.
      matrixHost = "matrix.autonomija.net";

      clientUrl = "https://${matrixHost}";
      statePath = "/var/lib/${config.services.matrix-tuwunel.stateDirectory}";
      registrationTokenFile = "${statePath}/registration-token";
      turnSecretFile = "/var/lib/matrix-turn/secret";
      turnAddress = "168.119.182.35";
      certificatePath = config.security.acme.certs.${matrixHost}.directory;

      wellKnownClient = ''
        default_type application/json;
        add_header Access-Control-Allow-Origin "*" always;
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
        # A different server name needs a fresh database. Keep the existing
        # anarhizam.org database in /var/lib/tuwunel intact for rollback.
        stateDirectory = "tuwunel-autonomija";
        settings.global = {
          server_name = serverName;
          oidc_native_auth = true;
          # Required to start the built-in OIDC server and set its issuer URL.
          well_known.client = clientUrl;
          address = [ "127.0.0.1" ];
          port = [ 8008 ];
          allow_federation = true;
          allow_registration = true;
          registration_token_file = registrationTokenFile;
          turn_uris = [
            "turn:${matrixHost}:3478?transport=udp"
            "turn:${matrixHost}:3478?transport=tcp"
            "turns:${matrixHost}:5349?transport=tcp"
          ];
          turn_secret_file = "/run/credentials/tuwunel.service/turn-secret";
        };
      };

      systemd.services.matrix-turn-secret = {
        description = "Generate the shared Matrix TURN secret";
        serviceConfig = {
          Type = "oneshot";
          RemainAfterExit = true;
          StateDirectory = "matrix-turn";
          StateDirectoryMode = "0700";
          UMask = "0077";
        };
        script = ''
          if [ ! -s ${turnSecretFile} ]; then
            ${lib.getExe pkgs.openssl} rand -hex 32 > ${turnSecretFile}.tmp
            mv ${turnSecretFile}.tmp ${turnSecretFile}
          fi
        '';
      };

      # Invite token, generated once and kept out of the nix store.
      # First account to register becomes the server admin.
      systemd.services.tuwunel = {
        requires = [ "matrix-turn-secret.service" ];
        after = [ "matrix-turn-secret.service" ];
        serviceConfig.LoadCredential = [ "turn-secret:${turnSecretFile}" ];
        preStart = ''
          if [ ! -s ${lib.escapeShellArg registrationTokenFile} ]; then
            umask 077
            ${lib.getExe pkgs.openssl} rand -hex 32 > ${lib.escapeShellArg registrationTokenFile}
          fi
        '';
      };

      services.coturn = {
        enable = true;
        realm = serverName;
        use-auth-secret = true;
        static-auth-secret-file = "/run/credentials/coturn.service/turn-secret";
        listening-ips = [ turnAddress ];
        relay-ips = [ turnAddress ];
        min-port = 49152;
        max-port = 49999;
        cert = "/run/credentials/coturn.service/tls-cert";
        pkey = "/run/credentials/coturn.service/tls-key";
        no-tcp-relay = true;
        extraConfig = ''
          no-multicast-peers
          denied-peer-ip=0.0.0.0-0.255.255.255
          denied-peer-ip=10.0.0.0-10.255.255.255
          denied-peer-ip=100.64.0.0-100.127.255.255
          denied-peer-ip=127.0.0.0-127.255.255.255
          denied-peer-ip=169.254.0.0-169.254.255.255
          denied-peer-ip=172.16.0.0-172.31.255.255
          denied-peer-ip=192.168.0.0-192.168.255.255
          denied-peer-ip=::1
          denied-peer-ip=fc00::-fdff:ffff:ffff:ffff:ffff:ffff:ffff:ffff
          denied-peer-ip=fe80::-febf:ffff:ffff:ffff:ffff:ffff:ffff:ffff
        '';
      };

      systemd.services.coturn = {
        requires = [ "matrix-turn-secret.service" ];
        wants = [ "acme-${matrixHost}.service" ];
        after = [
          "matrix-turn-secret.service"
          "acme-${matrixHost}.service"
        ];
        serviceConfig.LoadCredential = [
          "turn-secret:${turnSecretFile}"
          "tls-cert:${certificatePath}/fullchain.pem"
          "tls-key:${certificatePath}/key.pem"
        ];
      };

      security.acme.certs.${matrixHost}.reloadServices = [ "coturn.service" ];

      networking.firewall = {
        allowedTCPPorts = [
          3478
          5349
        ];
        allowedUDPPorts = [ 3478 ];
        allowedUDPPortRanges = [
          {
            from = config.services.coturn.min-port;
            to = config.services.coturn.max-port;
          }
        ];
      };

      services.nginx = {
        enable = true;
        virtualHosts = {
          ${matrixHost} = {
            forceSSL = true;
            enableACME = true;
            extraConfig = ''
              client_max_body_size 20m;
            '';
            locations = {
              # Classic Element cannot handle registration-token UIA itself.
              # Serve its web fallback and return credentials through its bridge.
              "= /_matrix/static/client/register" = {
                extraConfig = ''
                  return 302 /_matrix/static/client/register/$is_args$args;
                '';
              };
              "/_matrix/static/client/register/" = {
                alias = "${./matrix-registration}/";
                index = "index.html";
                extraConfig = ''
                  add_header Cache-Control "no-store" always;
                  add_header Referrer-Policy "no-referrer" always;
                  add_header X-Content-Type-Options "nosniff" always;
                  add_header X-Frame-Options "DENY" always;
                  # Android injects its bridge using a javascript: URL.
                  add_header Content-Security-Policy "default-src 'none'; script-src 'self' 'unsafe-inline'; style-src 'self'; connect-src 'self'; frame-src js:; frame-ancestors 'none'; form-action 'self'; base-uri 'none'" always;
                '';
              };
              "/_matrix" = {
                proxyPass = "http://127.0.0.1:8008";
                proxyWebsockets = true;
                recommendedProxySettings = true;
              };
              "/_tuwunel/oidc/" = {
                proxyPass = "http://127.0.0.1:8008";
                recommendedProxySettings = true;
              };
              "= /.well-known/openid-configuration" = {
                proxyPass = "http://127.0.0.1:8008";
                recommendedProxySettings = true;
              };
              "= /.well-known/matrix/client" = {
                extraConfig = wellKnownClient;
              };
            };
          };
          # Serve discovery over HTTPS on the homeserver name. Federation
          # uses the API host on port 443 rather than an 8448 listener.
          ${serverName} = {
            forceSSL = true;
            enableACME = true;
            locations = {
              "= /.well-known/matrix/client" = {
                extraConfig = wellKnownClient;
              };
              "= /.well-known/matrix/server" = {
                extraConfig = wellKnownServer;
              };
            };
          };
        };
      };
    };
}
