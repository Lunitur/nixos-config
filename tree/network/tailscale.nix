{ ... }: {
  flake.modules.nixos.network.tailscale = {
    networking.firewall = {
      trustedInterfaces = [ "tailscale0" ];
      checkReversePath = "loose";
      allowedUDPPorts = [ 41641 3478 ];
    };
    services.tailscale = { enable = true; openFirewall = true; };
  };
}
