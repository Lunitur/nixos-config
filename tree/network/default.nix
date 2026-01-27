{ config, ... }: {
  flake.modules.nixos.network.default = { lib, ... }: {
    imports = [
      config.flake.modules.nixos.network.avahi
      config.flake.modules.nixos.network.spotify
      config.flake.modules.nixos.network.syncthing
      config.flake.modules.nixos.network.tailscale
      config.flake.modules.nixos.network.moonlight
    ];
    networking.networkmanager = { enable = true; dns = "systemd-resolved"; wifi.powersave = true; };
    services.openssh = { enable = true; settings.UseDns = true; };
    services.resolved.enable = true;
    systemd.services.NetworkManager-wait-online.enable = lib.mkForce false;
    networking.firewall.allowedUDPPorts = [ 67 68 ];
  };
}
