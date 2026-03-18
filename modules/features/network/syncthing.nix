{ ... }:
{
  flake.nixosModules.syncthing =
    { config, lib, ... }:
    {
      networking.firewall = {
        allowedUDPPorts = [
          22000
          21027
        ];
        allowedTCPPorts = [
          42355
          22000
        ];
      };
    };
}
