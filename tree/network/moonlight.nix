{ ... }: {
  flake.modules.nixos.network.moonlight = {
    networking.firewall = {
      allowedUDPPorts = [ 47998 47999 48000 ];
      allowedTCPPorts = [ 47984 47989 47990 48010 ];
    };
  };
}
