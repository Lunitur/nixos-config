{ config, lib, ... }:
let
  cfg = config.features.network;
in
{
  options.features.network = {
    base.enable = lib.mkEnableOption "Base networking configuration";
    tailscale.enable = lib.mkEnableOption "Tailscale VPN";
    syncthing.enable = lib.mkEnableOption "Syncthing sync service";
    spotify.enable = lib.mkEnableOption "Spotify networking";
    avahi.enable = lib.mkEnableOption "Avahi mDNS/DNS-SD";
    moonlight.enable = lib.mkEnableOption "Moonlight streaming";
    headscale.enable = lib.mkEnableOption "Headscale (Tailscale control server)";
  };

  imports = [
    ./tailscale-feature.nix
    ./syncthing-feature.nix
    ./spotify-feature.nix
    ./avahi-feature.nix
    ./moonlight-feature.nix
    ./headscale-feature.nix
  ];

  config = lib.mkIf cfg.base.enable (import ./base.nix { inherit lib; });
}