{
  inputs,
  ...
}:
{
  flake.modules.nixos.minibook-base = {
    config,
    lib,
    pkgs,
    pkgs-unstable,
    ...
  }:
  let
    monitor = import ../../../scripts/monitor.nix { inherit pkgs; };
  in
  {
    imports = [
      inputs.self.modules.nixos.minibook-hardware
      inputs.self.modules.nixos.user-carjin
    ];

    features.services.jupyter.enable = true;

    programs.niri.enable = true;

    programs.nix-index-database.comma.enable = true;

    environment.systemPackages =
      (with pkgs-unstable; [
      ])
      ++ (with pkgs; [
      ]);

    services.upower.enable = true;
    services.upower.percentageAction = 5;

    virtualisation.waydroid.enable = true;

    services.xserver.enable = true;
    services.displayManager.sddm = {
      enable = true;
      wayland.enable = true;
      settings = {
        Autologin = {
          Session = "niri.desktop";
          User = "carjin";
        };
      };
    };

    programs.wireshark.enable = true;

    programs.steam = {
      enable = true;
      remotePlay.openFirewall = true; # Open ports in the firewall for Steam Remote Play
      dedicatedServer.openFirewall = true; # Open ports in the firewall for Source Dedicated Server
      localNetworkGameTransfers.openFirewall = true; # Open ports in the firewall for Steam Local Network Game Transfers
    };

    boot.initrd.systemd.enable = true;
    services.logind.settings.Login.HandleLidSwitch = "hibernate"; # "hybrid-sleep";

    boot.loader.systemd-boot.enable = true;
    boot.loader.efi.canTouchEfiVariables = true;

    boot.kernelPackages = pkgs.linuxPackages_zen;
    boot.kernelParams = [
      "video=DSI-1:1200x1920@75"
    ];
    boot.loader.systemd-boot.consoleMode = "0";

    networking.hostName = "minibook";

    services.blueman.enable = true;
    hardware.bluetooth.enable = true;

    powerManagement = {
      enable = true;
      powertop.enable = true;
    };

    hardware.graphics = {
      enable = true;
    };

    system.stateVersion = "25.05";

  };
}
