{ config, lib, ... }:
let
  cfg = config.features.network.tailscale;
in
{
  config = lib.mkIf cfg.enable {
    networking.firewall = {
      trustedInterfaces = [ "tailscale0" ];
      # required to connect to Tailscale exit nodes
      checkReversePath = "loose";
    };

    networking.firewall.allowedUDPPorts = [
      41641
      3478
    ];

    # inter-machine VPN
    services.tailscale = {
      enable = true;
      openFirewall = true;
    };
  };
}
