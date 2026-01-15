{ config, pkgs, ... }:
{
  services.headscale = {
    enable = true;
    address = "127.0.0.1";
    port = 8080;
    settings = {
      server_url = "https://headscale.anarhizam.org";
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
}
