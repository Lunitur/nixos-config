{ ... }: {
  flake.modules.nixos.network.spotify = {
    networking.firewall.allowedTCPPorts = [ 57621 ];
  };
}
