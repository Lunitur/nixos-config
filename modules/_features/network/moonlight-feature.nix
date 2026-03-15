{ config, lib, ... }:
let
  cfg = config.features.network.moonlight;
in
{
  config = lib.mkIf cfg.enable {
    networking.firewall = {
      allowedUDPPorts = [
        47998
        47999
        48000
      ];

      allowedTCPPorts = [
        47984
        47989
        47990
        48010
      ];
    };
  };
}
