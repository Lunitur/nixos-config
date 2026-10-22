{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.services.sus-grav;
  php = pkgs.php84.withExtensions (
    { enabled, all }:
    enabled
    ++ [
      all.gd
      all.zip
      all.mbstring
      all.apcu
      all.intl
    ]
  );
  archive = pkgs.fetchurl {
    url = "https://github.com/getgrav/grav/releases/download/2.2.8/grav-admin-v2.2.8.zip";
    hash = "sha256-6c0Q7zTQgodbw6TpChFHLzHDElxIUCP9+pRJglBJ+Ik=";
  };
  grav = pkgs.runCommand "grav-admin-2.2.8" { nativeBuildInputs = [ pkgs.unzip ]; } ''
    unzip -q ${archive}
    mv grav-admin "$out"
  '';
  root = cfg.dataDir;
  ready = "if (!-f ${root}/.site-ready) { return 503; }";
  adminUser = pkgs.writeShellApplication {
    name = "sus-grav-user";
    runtimeInputs = [ php ];
    text = ''
      cd ${lib.escapeShellArg root}
      exec php bin/plugin login new-user --admin-type api "$@"
    '';
  };
  pushSite = pkgs.writeShellApplication {
    name = "sus-grav-push";
    runtimeInputs = [ pkgs.git ];
    text = ''
      repository=/home/carjin/sus-glavna
      if [[ ! -O "$repository" ]] || [[ "$(git -C "$repository" rev-parse --is-bare-repository)" != true ]]; then
        echo "Run as carjin with a bare repository at $repository." >&2
        exit 1
      fi

      site_git() {
        ${config.security.wrapperDir}/sudo -u sus-grav ${pkgs.git}/bin/git -C ${lib.escapeShellArg root} "$@"
      }

      branch="$(site_git symbolic-ref --short HEAD)"
      site_git add --all
      if ! site_git diff --cached --quiet; then
        site_git diff --cached --stat
        site_git commit -m "''${1:-Update site content}"
      fi

      git -C "$repository" fetch --no-tags \
        --upload-pack="${config.security.wrapperDir}/sudo -u sus-grav ${pkgs.git}/bin/git-upload-pack" \
        ${lib.escapeShellArg root} "$branch:refs/heads/$branch"
    '';
  };
  pullSite = pkgs.writeShellApplication {
    name = "sus-grav-pull";
    runtimeInputs = [ pkgs.git ];
    text = ''
      umask 0027
      repository=/home/carjin/sus-glavna
      if [[ ! -O "$repository" ]] || [[ "$(git -C "$repository" rev-parse --is-bare-repository)" != true ]]; then
        echo "Run as carjin with a bare repository at $repository." >&2
        exit 1
      fi

      site_git() {
        ${config.security.wrapperDir}/sudo -u sus-grav ${pkgs.git}/bin/git -C ${lib.escapeShellArg root} "$@"
      }

      branch="$(site_git symbolic-ref --short HEAD)"
      if [[ -n "$(site_git status --porcelain)" ]]; then
        echo "The live site has uncommitted changes. Run sus-grav-push first." >&2
        exit 1
      fi

      git -C "$repository" push \
        --receive-pack="${config.security.wrapperDir}/sudo -u sus-grav ${pkgs.git}/bin/git-receive-pack" \
        ${lib.escapeShellArg root} "$branch:refs/remotes/sus-local/$branch"
      site_git merge --ff-only "refs/remotes/sus-local/$branch"

      ${config.security.wrapperDir}/sudo -u sus-grav ${pkgs.coreutils}/bin/env \
        GRAV_ROOT=${lib.escapeShellArg root} GRAV_ENVIRONMENT=production \
        ${php}/bin/php ${lib.escapeShellArg "${root}/bin/grav"} clearcache
    '';
  };
in
{
  options.services.sus-grav = {
    enable = lib.mkEnableOption "Grav za Sindikat učenika i studenata";
    domain = lib.mkOption {
      type = lib.types.str;
      default = "sus.autonomija.net";
    };
    dataDir = lib.mkOption {
      type = lib.types.str;
      default = "/var/lib/sus-grav";
    };
  };

  config = lib.mkIf cfg.enable {
    users.users.sus-grav = {
      isSystemUser = true;
      group = "sus-grav";
      home = root;
    };
    users.groups.sus-grav = { };
    users.users.nginx.extraGroups = [ "sus-grav" ];
    environment.systemPackages = [
      adminUser
      pushSite
      pullSite
    ];
    systemd.tmpfiles.rules = [
      "d ${root} 0750 sus-grav sus-grav -"
      "d /var/backup/sus-grav 0700 sus-grav sus-grav -"
    ];

    systemd.services.sus-grav-init = {
      description = "Priprema trajne Grav instalacije";
      wantedBy = [ "multi-user.target" ];
      before = [
        "phpfpm-sus-grav.service"
        "nginx.service"
      ];
      path = [ pkgs.rsync ];
      serviceConfig = {
        Type = "oneshot";
        RemainAfterExit = true;
        User = "sus-grav";
        Group = "sus-grav";
        UMask = "0027";
      };
      script = ''
        if [ ! -f ${lib.escapeShellArg "${root}/.grav-installed"} ]; then
          rsync -r --chmod=u=rwX,g=rX,o= --exclude=/user/ ${grav}/ ${lib.escapeShellArg root}/
          touch ${lib.escapeShellArg "${root}/.grav-installed"}
        fi
        mkdir -p ${lib.escapeShellArg root}/user/{accounts,config,data,plugins,pages,themes}
        rsync -r --ignore-existing --chmod=u=rwX,g=rX,o= ${grav}/user/plugins/ ${lib.escapeShellArg root}/user/plugins/
      '';
    };

    services.phpfpm.pools.sus-grav = {
      user = "sus-grav";
      group = "sus-grav";
      phpPackage = php;
      phpEnv.GRAV_ENVIRONMENT = "production";
      settings = {
        "listen.owner" = "nginx";
        "listen.group" = "nginx";
        "listen.mode" = "0660";
        "pm" = "dynamic";
        "pm.max_children" = 8;
        "pm.start_servers" = 2;
        "pm.min_spare_servers" = 1;
        "pm.max_spare_servers" = 3;
        "pm.max_requests" = 500;
      };
      phpOptions = ''
        expose_php = Off
        upload_max_filesize = 20M
        post_max_size = 24M
        memory_limit = 256M
        opcache.enable = 1
      '';
    };
    systemd.services.phpfpm-sus-grav = {
      requires = [ "sus-grav-init.service" ];
      after = [ "sus-grav-init.service" ];
      serviceConfig.UMask = "0027";
    };

    services.nginx = {
      enable = true;
      virtualHosts.${cfg.domain} = {
        inherit root;
        forceSSL = true;
        enableACME = true;
        extraConfig = ''
          index index.php;
          client_max_body_size 24m;
          add_header X-Content-Type-Options nosniff always;
          add_header Referrer-Policy strict-origin-when-cross-origin always;

          location ~* ^/(cache|bin|logs|backup|tests|webserver-configs)(/|$) { return 403; }
          location ~* ^/(system|vendor)/.*\.(txt|xml|md|html|htm|shtml|json|yaml|yml|php[0-9]?|phar|phtml|pl|py|cgi|twig|sh|bat)$ { return 403; }
          location ~* ^/user/(config|env|accounts|data|blueprints)(/|$) { return 403; }
          location ~ /\. { return 403; }
          location ~* ^/user/.*\.(txt|md|json|yaml|yml|php[0-9]?|phar|phtml|pl|py|cgi|twig|sh|bat)$ { return 403; }
          location ~* \.(php[0-9]?|phar|phtml|yaml|yml|twig|md|lock)$ { return 403; }
          location ~* ^/(composer\.json|LICENSE\.txt|nginx\.conf|web\.config|htaccess\.txt|now\.json)$ { return 403; }
        '';
        locations."/".extraConfig = ''
          ${ready}
          try_files $uri $uri/ /index.php?$query_string;
        '';
        locations."= /index.php".extraConfig = ''
          ${ready}
          include ${pkgs.nginx}/conf/fastcgi_params;
          fastcgi_param SCRIPT_FILENAME $document_root/index.php;
          fastcgi_pass unix:${config.services.phpfpm.pools.sus-grav.socket};
        '';
      };
    };

    systemd.services.sus-grav-backup = {
      description = "Dnevna sigurnosna kopija Grav sadržaja";
      requires = [ "sus-grav-init.service" ];
      after = [ "sus-grav-init.service" ];
      path = [
        pkgs.gnutar
        pkgs.gzip
        pkgs.findutils
      ];
      serviceConfig = {
        Type = "oneshot";
        User = "sus-grav";
        Group = "sus-grav";
        UMask = "0077";
      };
      script = ''
        target="/var/backup/sus-grav/$(date -u +%Y-%m-%dT%H%M%SZ).tar.gz"
        tar -czf "$target.part" -C ${lib.escapeShellArg root} user
        mv "$target.part" "$target"
        find /var/backup/sus-grav -maxdepth 1 -name '*.tar.gz' -mtime +13 -delete
      '';
    };
    systemd.timers.sus-grav-backup = {
      wantedBy = [ "timers.target" ];
      timerConfig = {
        OnCalendar = "daily";
        Persistent = true;
        RandomizedDelaySec = "30m";
      };
    };
  };
}
