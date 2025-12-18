{
  config,
  lib,
  pkgs,
  inputs,
  modules,
  ...
}:
{
  imports = [
    ./hardware-configuration.nix
    ./common.nix
  ];

  environment.systemPackages = with pkgs; [
    helix
    zulu
  ];

  systemd.services.anarhizam-org = {
    description = "Anarhizam.org Server";

    after = [ "network.target" ];
    wantedBy = [ "multi-user.target" ];

    serviceConfig = {
      User = "carjin";
      ExecStart = "${pkgs.zulu}/bin/java -jar /home/carjin/anarhizam-org/anarhizam-org-0.1.0-SNAPSHOT-standalone.jar";

      Restart = "on-failure";
      RestartSec = "10s";
    };
  };

  security.acme.acceptTerms = true;
  security.acme.defaults.email = "karlo.puselj@gmail.com";
  services.nginx = {
    enable = true;
    virtualHosts = {
      "anarhizam.org" = {
        addSSL = true;
        enableACME = true;
        locations."/" = {
          proxyPass = "http://localhost:3000";
          recommendedProxySettings = true;
          proxyWebsockets = true;
        };
        locations."/.well-known/acme-challenge".root = "/var/lib/acme/acme-challenge";
      };

      "nextcloud.anarhizam.org" = {
        forceSSL = true;
        enableACME = true;
        locations."/.well-known/acme-challenge".root = "/var/lib/acme/acme-challenge";
      };
    };
  };

  mailserver = {
    enable = true;
    stateVersion = 3;
    fqdn = "mail.anarhizam.org";
    domains = [ "anarhizam.org" ];

    # A list of all login accounts. To create the password hashes, use
    # nix-shell -p mkpasswd --run 'mkpasswd -sm bcrypt'
    loginAccounts = {
      "karlo.puselj@anarhizam.org" = {
        hashedPasswordFile = "/etc/mail/karlo";
      };
      "carjin@anarhizam.org" = {
        hashedPasswordFile = "/etc/mail/carjin";
        # aliases = ["postmaster@example.com"];
      };
      "lsimek@anarhizam.org" = {
        hashedPasswordFile = "/etc/mail/lsimek";
      };
      "discourse@anarhizam.org" = {
        hashedPasswordFile = "/etc/mail/discourse";
      };
      "marko@anarhizam.org" = {
        hashedPasswordFile = "/etc/mail/marko";
      };
    };
    certificateScheme = "acme-nginx";
  };

  services.discourse = {
    enable = false;
    database.ignorePostgresqlVersion = true;
    admin = {
      username = "carjin";
      email = "carjin@anarhizam.org";
      fullName = "Carjin";
      passwordFile = "/etc/discourse/adminpass";

    };
    mail.outgoing = {
      username = "discourse@anarhizam.org";
      passwordFile = "/etc/discourse/mailpass";
      domain = "anarhizam.org";
      # forceTLS = true;
      authentication = "plain";
      serverAddress = "mail.anarhizam.org";
    };
    secretKeyBaseFile = "/etc/discourse/secretKeyBase";
    hostname = "discourse.anarhizam.org";

  };

  services.postgresql = {
    enable = true;
    ensureDatabases = [ "discourse" ];
    authentication = pkgs.lib.mkOverride 10 ''
      #type database  DBuser  auth-method
      local all       all     trust
    '';
    ensureUsers = [
      {
        name = "discourse";
        ensureDBOwnership = true;
      }
    ];
  };

  services.nextcloud = {
    enable = true;
    package = pkgs.nextcloud32;
    hostName = "nextcloud.anarhizam.org";
    https = true;
    config = {
      adminpassFile = "/etc/private/nextcloud-admin-pass";
      adminuser = "root";
      dbtype = "sqlite";
    };
    extraApps = {
      inherit (config.services.nextcloud.package.packages.apps)
        contacts
        calendar
        tasks
        richdocuments
        groupfolders
        deck
        ;
    };
    extraAppsEnable = true;
    settings =
      let
        prot = "https"; # or https
        host = "nextcloud.anarhizam.org";
        dir = "/";
      in
      {
        overwriteprotocol = prot;
        overwritehost = host;
        overwritewebroot = dir;
        overwrite.cli.url = "${prot}://${host}${dir}/";
        htaccess.RewriteBase = dir;
        trusted_domains = [
          "nano"
          "nano.akita-bleak.ts.net"
          "localhost"
          "nextcloud.anarhizam.org"
        ];
        log_type = "file";
      };
  };

  # virtualisation.docker = {
  #   rootless = {
  #     enable = true;
  #     setSocketVariable = true;
  #   };
  # };

  virtualisation.oci-containers.containers.collabora = {
    image = "docker.io/collabora/code:latest";
    ports = [ "9980:9980/tcp" ];
    environment = {
      server_name = "office.anarhizam.org";
      aliasgroup1 = "https://nextcloud.anarhizam.org:443";
      dictionaries = "en_US hr_HR";
      username = "username";
      password = "password";
      extra_params = "--o:ssl.enable=false --o:ssl.termination=true --o:per_document.max_concurrency=2";
    };
    extraOptions = [
      "--pull=newer"
    ];
  };

  #Collabora Virtual Hosts
  services.nginx.virtualHosts.${config.virtualisation.oci-containers.containers.collabora.environment.server_name} =
    {
      enableACME = true;
      addSSL = true;

      extraConfig = ''
         # static files
         location ^~ /browser {
           proxy_pass http://127.0.0.1:9980;
           proxy_set_header Host $host;
         }

         # WOPI discovery URL
         location ^~ /hosting/discovery {
           proxy_pass http://127.0.0.1:9980;
           proxy_set_header Host $host;
         }

         # Capabilities
         location ^~ /hosting/capabilities {
           proxy_pass http://127.0.0.1:9980;
           proxy_set_header Host $host;
        }

        # main websocket
        location ~ ^/cool/(.*)/ws$ {
          proxy_pass http://127.0.0.1:9980;
          proxy_set_header Upgrade $http_upgrade;
          proxy_set_header Connection "Upgrade";
          proxy_set_header Host $host;
          proxy_read_timeout 36000s;
        }

        # download, presentation and image upload
        location ~ ^/(c|l)ool {
          proxy_pass http://127.0.0.1:9980;
          proxy_set_header Host $host;
        }

        # Admin Console websocket
        location ^~ /cool/adminws {
          proxy_pass http://127.0.0.1:9980;
          proxy_set_header Upgrade $http_upgrade;
          proxy_set_header Connection "Upgrade";
          proxy_set_header Host $host;
          proxy_read_timeout 36000s;
        }
      '';
    };

  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  # boot.kernelPackages = pkgs.linuxPackages_zen;

  networking.hostName = "nano";
  networking.firewall = {
    allowedUDPPorts = [
      80
      443
      9980
    ];
    allowedTCPPorts = [
      80
      443
      9980
    ];
  };

  networking.interfaces.enp1s0.useDHCP = true;

  system.stateVersion = "24.05";

}
