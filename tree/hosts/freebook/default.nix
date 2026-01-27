{ config, pkgs, pkgs-unstable, ... }: {
  flake.modules.nixos.hosts.freebook.default = { config, lib, pkgs, ... }: {
    imports = [
      config.flake.modules.nixos.hosts.freebook.hardware
      config.flake.modules.nixos.hosts.freebook.monitor
      config.flake.modules.nixos.hyprland
      ../../../../users/lsimek/user.nix
    ];

    home-manager = {
      extraSpecialArgs = {
        inherit pkgs-unstable;
      };
      users = {
        lsimek = ../../../../users/lsimek/home.nix;
      };

      backupFileExtension = "backup";
      useGlobalPkgs = true;
    };

    environment.systemPackages =
      (with pkgs-unstable; [
        jetbrains.idea-community-bin
      ])
      ++ (with pkgs; [
        virtiofsd # libvirt folder sharing
        moonlight-qt
        wireshark
        tshark
        nikto
        logseq
        youtube-music
        ghostwriter
      ]);

    services.upower.enable = true;
    services.upower.percentageAction = 5;

    services.xserver.enable = true;
    services.displayManager.sddm = {
      enable = true;
      wayland.enable = true;
      settings = {
        Autologin = {
          Session = "hyprland-uwsm.desktop";
          User = "lsimek";
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

    swapDevices = [ { device = "/var/swapfile"; } ];
    services.logind.lidSwitch = "hybrid-sleep";

    boot.loader.systemd-boot.enable = true;
    boot.loader.efi.canTouchEfiVariables = true;

    boot.kernelPackages = pkgs.linuxPackages_zen;
    boot.loader.systemd-boot.consoleMode = "0";

    networking.hostName = "freebook";

    services.blueman.enable = true;
    hardware.bluetooth.enable = true;

    powerManagement = {
      enable = true;
      powertop.enable = true;
    };

    hardware.graphics = {
      enable = true;
    };

    system.stateVersion = "24.11";
  };
}
