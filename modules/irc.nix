{ config, pkgs, lib, ... }:

{
  networking.firewall.allowedTCPPorts = [ 6667 6697 ];

  services.ergochat = {
    enable = true;
    settings = {
      network.name = "Anarhizam IRC";
      server = {
        name = "irc.anarhizam.org";
        listeners = {
          ":6667" = {};
          "127.0.0.1:8081" = {}; # Auto-detects WebSockets
          ":6697" = {
            tls = {
              cert = "/var/lib/acme/irc.anarhizam.org/cert.pem";
              key = "/var/lib/acme/irc.anarhizam.org/key.pem";
            };
          };
        };
      };
    };
  };

  systemd.services.ergochat.serviceConfig.SupplementaryGroups = [ "nginx" ];

  services.nginx.virtualHosts."irc.anarhizam.org" = {
    enableACME = true;
    forceSSL = true;
    root = pkgs.gamja;
    
    locations."/" = {
      tryFiles = "$uri $uri/ /index.html";
    };

    locations."/config.json".alias = pkgs.writeText "gamja-config.json" ''
      {
        "server": {
          "url": "wss://irc.anarhizam.org/webirc/",
          "name": "Anarhizam IRC",
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
