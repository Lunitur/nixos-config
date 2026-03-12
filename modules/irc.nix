{ config, pkgs, lib, ... }:

let
  isProd = config.networking.hostName == "nano";
  domain = if isProd then "irc.anarhizam.org" else "irc.local";
  useACME = isProd;
in
{
  networking.firewall.allowedTCPPorts = [ 6667 6697 80 443 ];

  services.nginx.enable = true;

  services.ergochat = {
    enable = true;
    settings = {
      network.name = "AnarhizamIRC";
      server = {
        name = domain;
        enforce-utf8 = true;
        listeners = {
          ":6667" = {};
          "127.0.0.1:8081" = { websocket = true; }; # Explicitly enable WebSockets
        } // lib.optionalAttrs isProd {
          ":6697" = {
            tls = {
              cert = "/var/lib/acme/${domain}/cert.pem";
              key = "/var/lib/acme/${domain}/key.pem";
            };
          };
        };
      };
    };
  };

  systemd.services.ergochat.serviceConfig.SupplementaryGroups = [ "nginx" ];

  services.nginx.virtualHosts."${domain}" = {
    enableACME = useACME;
    forceSSL = useACME;
    root = pkgs.gamja;
    
    locations."/" = {
      tryFiles = "$uri $uri/ /index.html";
    };

    locations."= /config.json".alias = pkgs.writeText "gamja-config.json" ''
      {
        "server": {
          "url": "''${if useACME then "wss" else "ws"}://''${domain}/webirc/",
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
}