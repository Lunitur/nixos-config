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
  ];

  environment.systemPackages = with pkgs; [
    helix
  ];

  security.acme.acceptTerms = true;
  security.acme.defaults.email = "karlo.puselj@gmail.com";
  services.nginx = {
    enable = true;
    virtualHosts = {
      "anarhizam.org" = {
        addSSL = true;
        enableACME = true;
        # All serverAliases will be added as extra domain names on the certificate.
        # serverAliases = [ "nextcloud.anarhizam.org" ];
        locations."/" = {
          root = "/var/www";
        };
        locations."/.well-known/acme-challenge".root = "/var/lib/acme/acme-challenge";
      };

      # We can also add a different vhost and reuse the same certificate
      # but we have to append extraDomainNames manually beforehand:
      "nextcloud.anarhizam.org" = {
        forceSSL = true;
        enableACME = true;
        # locations."/" = {
        #   root = "/var/mail";
        # };
        locations."/.well-known/acme-challenge".root = "/var/lib/acme/acme-challenge";
      };

      "ai.anarhizam.org" = {
        enableACME = true;
        addSSL = true;
        locations."/" = {
          proxyPass = "http://centaur.akita-bleak.ts.net:8080";
          recommendedProxySettings = true;
        };
        locations."/.well-known/acme-challenge".root = "/var/lib/acme/acme-challenge";
      };
    };
  };

  mailserver = {
    enable = true;
    fqdn = "mail.anarhizam.org";
    domains = [ "anarhizam.org" ];

    # A list of all login accounts. To create the password hashes, use
    # nix-shell -p mkpasswd --run 'mkpasswd -sm bcrypt'
    loginAccounts = {
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
    enable = true;
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
    package = pkgs.nextcloud30;
    hostName = "nextcloud.anarhizam.org";
    https = true;
    config = {
      adminpassFile = "/etc/private/nextcloud-admin-pass";
      adminuser = "root";
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
          "pico"
          "pico.akita-bleak.ts.net"
          "localhost"
          "nextcloud.anarhizam.org"
        ];
        log_type = "file";
      };
  };

  virtualisation.docker = {
    rootless = {
      enable = true;
      setSocketVariable = true;
    };
  };

  virtualisation.oci-containers.containers.collabora = {
    image = "docker.io/collabora/code:latest";
    ports = [ "9980:9980/tcp" ];
    environment = {
      server_name = "office.anarhizam.org";
      aliasgroup1 = "https://nextcloud.anarhizam.org:443";
      dictionaries = "en_US";
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

  networking.hostName = "pico";
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

  system.stateVersion = "24.05";

}
