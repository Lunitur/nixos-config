{ ... }:
{
  flake.nixosModules.irc-anarhizam-org =
    {
      config,
      pkgs,
      lib,
      ...
    }:
    let
      isNano = config.networking.hostName == "nano";
      ircDomain = if isNano then "irc.anarhizam.org" else "irc.local";
      ircUseACME = isNano;
    in
    {
      networking.firewall.allowedTCPPorts = [
        6667
        6697
        80
        443
      ];
      services.ergochat = {
        enable = true;
        settings = {
          network.name = "AnarhizamIRC";
          server = {
            name = ircDomain;
            enforce-utf8 = true;
            listeners = {
              ":6667" = { };
              "127.0.0.1:8081" = {
                websocket = true;
              };
            }
            // lib.optionalAttrs isNano {
              ":6697" = {
                tls = {
                  cert = "/var/lib/acme/${ircDomain}/cert.pem";
                  key = "/var/lib/acme/${ircDomain}/key.pem";
                };
              };
            };
          };
        };
      };
      services.nginx.virtualHosts."${ircDomain}" = {
        enableACME = ircUseACME;
        forceSSL = ircUseACME;
        root = pkgs.gamja;
        locations."/" = {
          tryFiles = "$uri $uri/ /index.html";
        };
        locations."= /config.json".alias = pkgs.writeText "gamja-config.json" ''
          {
            "server": {
              "url": "${if ircUseACME then "wss" else "ws"}://${ircDomain}/webirc/",
              "name": "AnarhizamIRC",
              "autoconnect": true
            }
          }
        '';
        locations."/webirc/" = {
          proxyPass = "http://127.0.0.1:8081/";
          proxyWebsockets = true;
          extraConfig = ''
            proxy_set_header X-Forwarded-For $remote_addr;
            proxy_set_header X-Forwarded-Proto $scheme;
          '';
        };
      };
      services.nginx.enable = true;
      systemd.services.ergochat.serviceConfig.SupplementaryGroups = [ "nginx" ];
    };
}
