{ ... }:
{
  flake.nixosModules.nano =
    { config, ... }:
    {
      services.atuin = {
        enable = true;
        host = "127.0.0.1";
        port = 8888;
        path = "/atuin";
        openRegistration = true;
        database.createLocally = true;
      };

      services.nginx.virtualHosts."anarhizam.org".locations = {
        "/atuin" = {
          proxyPass = "http://127.0.0.1:${toString config.services.atuin.port}";
          recommendedProxySettings = true;
        };
        # Register locally over SSH; public clients can only log in and sync.
        "= /atuin/register".extraConfig = "deny all;";
      };
    };
}
