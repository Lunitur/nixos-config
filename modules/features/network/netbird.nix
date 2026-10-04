{ ... }:
{
  flake.nixosModules.netbird =
    { config, pkgs, ... }:
    {
      services.netbird = {
        enable = true;
        clients.default = {
          # Keep the local DNS listener on loopback. Queries to our own tunnel
          # address can be intercepted by the overlay's routing/firewall rules.
          dns-resolver.address = "127.0.0.123";
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
        };
      };
    };
}
