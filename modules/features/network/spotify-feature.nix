{ config, lib, ... }:
let
  cfg = config.features.network.spotify;
in
{
  config = lib.mkIf cfg.enable {
    # Spotify track sync with other devices
    networking.firewall.allowedTCPPorts = [ 57621 ];
  };
}
