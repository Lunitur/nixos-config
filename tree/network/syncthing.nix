{ ... }: {
  flake.modules.nixos.network.syncthing = {
    networking.firewall = {
      allowedUDPPorts = [ 22000 21027 ];
      allowedTCPPorts = [ 42355 22000 ];
    };
  };
}
