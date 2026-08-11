{ ... }:
{
  flake.nixosModules.headscale =
    { config, lib, ... }:
    {
      services.headscale = {
        enable = true;
        address = "127.0.0.1";
        port = 8080;
        settings = {
          server_url = "https://headscale.anarhizam.org";
          derp = {
            server = {
              enabled = true;
              region_id = 999;
              region_code = "nano";
              region_name = "Nano";
              verify_clients = true;
              stun_listen_addr = "0.0.0.0:3478";
              automatically_add_embedded_derp_region = true;
              ipv4 = "168.119.182.35";
            };

            urls = [ ];
            auto_update_enabled = false;
          };
          dns = {
            base_domain = "ts.anarhizam.org";
            nameservers.global = [
              "1.1.1.1"
              "1.0.0.1"
            ];
          };
        };
      };

      environment.systemPackages = [ config.services.headscale.package ];
    };
}
