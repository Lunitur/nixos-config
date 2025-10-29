{ config, pkgs, ... }:

{
  # Matrix-synapse configuration
  #
  # See https://nixos.wiki/wiki/Matrix
  # and https://nixos.org/manual/nixos/stable/index.html#module-services-matrix-synapse
  # for more documentation.

  services.matrix-synapse = {
    enable = true;
    # Replace "matrix.example.com" with your own domain.
    server_name = "matrix.example.com";
    listeners = [
      {
        port = 8008;
        bind_address = "127.0.0.1";
        type = "http";
        tls = false;
        x_forwarded = true;
        resources = [{
          names = [ "client" "federation" ];
          compress = false;
        }];
      }
    ];
    # Open registration for new users.
    # Be careful with this option on public servers.
    settings.enable_registration = true;
  };

  # Nginx reverse proxy for Matrix
  services.nginx = {
    enable = true;
    virtualHosts."matrix.example.com" = {
      forceSSL = true;
      enableACME = true; # Use Let's Encrypt for SSL certificates
      locations."/_matrix" = {
        proxyPass = "http://127.0.0.1:8008";
        proxyWebsockets = true;
      };
    };
  };
}