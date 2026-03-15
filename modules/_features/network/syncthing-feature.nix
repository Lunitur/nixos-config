{ config, lib, ... }:
let
  cfg = config.features.network.syncthing;
in
{
  config = lib.mkIf cfg.enable {
    networking.firewall = {
      allowedUDPPorts = [
        # syncthing QUIC
        22000
        # syncthing discovery broadcast on ipv4 and multicast ipv6
        21027
      ];

      allowedTCPPorts = [
        42355
        # syncthing
        22000
      ];
    };
  };
}
