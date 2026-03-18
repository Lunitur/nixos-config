{ ... }:
{
  flake.nixosModules.spotify =
    { config, lib, ... }:
    {
      networking.firewall.allowedTCPPorts = [ 57621 ];
    };
}
