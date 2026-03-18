{ ... }:
{
  flake.nixosModules.network-base =
    { lib, config, ... }:
    {
      networking.networkmanager = {
        enable = true;
        dns = "systemd-resolved";
        wifi.powersave = true;
      };

      services = {
        openssh = {
          enable = true;
          settings.UseDns = true;
        };
        resolved.enable = true;
      };

      systemd.services.NetworkManager-wait-online.enable = lib.mkForce false;

      networking.firewall.allowedUDPPorts = [
        67
        68
      ];
    };
}
