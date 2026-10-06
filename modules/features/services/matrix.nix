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
        };
      };

      # Invite token, generated once and kept out of the nix store.
      # First account to register becomes the server admin.
      systemd.services.tuwunel.preStart = ''
        if [ ! -s ${lib.escapeShellArg registrationTokenFile} ]; then
          umask 077
          ${lib.getExe pkgs.openssl} rand -hex 32 > ${lib.escapeShellArg registrationTokenFile}
        fi
      '';

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
