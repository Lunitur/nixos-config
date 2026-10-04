{ ... }:
{
  flake.nixosModules.netbird =
    { config, pkgs, ... }:
    {
      services.netbird = {
        enable = true;
        clients.default = {
          environment = {
            NB_MANAGEMENT_URL = "https://netbird.anarhizam.org";
            NB_ADMIN_URL = "https://netbird.anarhizam.org";
          };
          config = {
            ManagementURL = {
              Scheme = "https";
              Host = "netbird.anarhizam.org:443";
            };
            AdminURL = {
              Scheme = "https";
              Host = "netbird.anarhizam.org";
            };
          };
          login = {
            enable = true;
            setupKeyFile = "/etc/netbird/setup-key";
          };
        };
      };

      # First activation can precede enrollment. Retry when the key is installed
      # or the management server becomes reachable, without blocking boot.
      systemd.services.netbird-login = {
        unitConfig.ConditionPathExists = "/etc/netbird/setup-key";
        serviceConfig.TimeoutStartSec = "90s";
      };
      systemd.timers.netbird-login = {
        wantedBy = [ "timers.target" ];
        timerConfig = {
          OnBootSec = "30s";
          OnUnitInactiveSec = "5min";
        };
      };

      environment.systemPackages = [
        (pkgs.writeShellApplication {
          name = "netbird-enroll";
          runtimeInputs = [ pkgs.coreutils ];
          text = ''
            if [[ $EUID -ne 0 ]]; then
              echo "Run sudo netbird-enroll to install this host's setup key." >&2
              exit 1
            fi
            read -r -s -p "NetBird setup key: " setup_key
            echo
            if [[ -z "$setup_key" ]]; then
              echo "The setup key must not be empty." >&2
              exit 1
            fi
            install -d -m 700 /etc/netbird
            umask 077
            printf '%s\n' "$setup_key" > /etc/netbird/setup-key
            unset setup_key
            systemctl restart netbird-login.service
            ${config.services.netbird.clients.default.wrapper}/bin/netbird status
          '';
        })
      ];
    };
}
