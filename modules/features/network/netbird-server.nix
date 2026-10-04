{ ... }:
{
  flake.nixosModules.netbird-server =
    { pkgs, ... }:
    let
      domain = "netbird.anarhizam.org";
      url = "https://${domain}";
      backend = "127.0.0.1:33073";
      publicConfig = (pkgs.formats.json { }).generate "netbird-server-public.json" {
        server = {
          listenAddress = backend;
          exposedAddress = "${url}:443";
          # Headscale's embedded DERP already owns UDP 3478 on Nano.
          stunPorts = [ 3479 ];
          metricsPort = 19090;
          healthcheckAddress = "127.0.0.1:19000";
          logLevel = "info";
          logFile = "console";
          dataDir = "/var/lib/netbird-server";
          disableAnonymousMetrics = true;
          disableGeoliteUpdate = true;
          auth = {
            issuer = "${url}/oauth2";
            signKeyRefreshEnabled = true;
            dashboardRedirectURIs = [
              "${url}/nb-auth"
              "${url}/nb-silent-auth"
            ];
            cliRedirectURIs = [ "http://localhost:53000/" ];
          };
          reverseProxy = {
            trustedHTTPProxies = [ "127.0.0.1/32" ];
            trustedPeers = [ "127.0.0.1/32" ];
          };
          store.engine = "sqlite";
        };
      };
      httpProxy = {
        proxyPass = "http://${backend}";
        recommendedProxySettings = true;
        proxyWebsockets = true;
        extraConfig = ''
          proxy_read_timeout 1d;
          proxy_send_timeout 1d;
        '';
      };
      grpcProxy.extraConfig = ''
        grpc_pass grpc://${backend};
        grpc_set_header X-Forwarded-For $remote_addr;
        grpc_read_timeout 1d;
        grpc_send_timeout 1d;
        grpc_socket_keepalive on;
      '';
    in
    {
      networking.firewall = {
        allowedTCPPorts = [
          80
          443
        ];
        allowedUDPPorts = [ 3479 ];
      };

      services.netbird.server.dashboard = {
        enable = true;
        enableNginx = true;
        inherit domain;
        managementServer = url;
        settings = {
          AUTH_AUTHORITY = "${url}/oauth2";
          AUTH_AUDIENCE = "netbird-dashboard";
          AUTH_CLIENT_ID = "netbird-dashboard";
          AUTH_SUPPORTED_SCOPES = "openid profile email groups";
          AUTH_REDIRECT_URI = "/nb-auth";
          AUTH_SILENT_REDIRECT_URI = "/nb-silent-auth";
        };
      };

      services.nginx.virtualHosts.${domain} = {
        forceSSL = true;
        enableACME = true;
        http2 = true;
        extraConfig = ''
          client_header_timeout 1d;
          client_body_timeout 1d;
        '';
        locations = {
          "/api" = httpProxy;
          "/oauth2" = httpProxy;
          "/relay" = httpProxy;
          "/ws-proxy/" = httpProxy;
          "/signalexchange.SignalExchange/" = grpcProxy;
          "/management.ManagementService/" = grpcProxy;
          "/management.ProxyService/" = grpcProxy;
        };
      };

      systemd.services.netbird-server = {
        description = "NetBird management, embedded identity provider, signal, relay and STUN";
        wantedBy = [ "multi-user.target" ];
        wants = [ "network-online.target" ];
        after = [ "network-online.target" ];
        path = [
          pkgs.coreutils
          pkgs.openssl
          pkgs.jq
        ];
        preStart = ''
          set -eu
          umask 077
          for secret in relay-secret datastore-key session-key; do
            if [ ! -s "$STATE_DIRECTORY/$secret" ]; then
              openssl rand -base64 32 > "$STATE_DIRECTORY/$secret.tmp"
              mv "$STATE_DIRECTORY/$secret.tmp" "$STATE_DIRECTORY/$secret"
            fi
          done
          # JSON is valid YAML. Keep credentials outside the Nix store and
          # preserve the encryption keys across rebuilds and restarts.
          jq --rawfile relay "$STATE_DIRECTORY/relay-secret" \
            --rawfile datastore "$STATE_DIRECTORY/datastore-key" \
            --rawfile session "$STATE_DIRECTORY/session-key" \
            '.server.authSecret = ($relay | rtrimstr("\n")) |
             .server.store.encryptionKey = ($datastore | rtrimstr("\n")) |
             .server.auth.sessionCookieEncryptionKey = ($session | rtrimstr("\n"))' \
            ${publicConfig} > "$RUNTIME_DIRECTORY/config.yaml"
        '';
        serviceConfig = {
          ExecStart = "${pkgs.netbird-combined}/bin/netbird-server --config /run/netbird-server/config.yaml";
          Restart = "on-failure";
          RestartSec = "5s";
          DynamicUser = true;
          StateDirectory = "netbird-server";
          StateDirectoryMode = "0700";
          RuntimeDirectory = "netbird-server";
          RuntimeDirectoryMode = "0700";
          UMask = "0077";
          ProtectSystem = "strict";
          ProtectHome = true;
          PrivateTmp = true;
          NoNewPrivileges = true;
        };
      };
    };
}
