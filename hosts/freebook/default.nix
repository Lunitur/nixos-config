{
  config,
  lib,
  pkgs,
  pkgs-unstable,
  inputs,
  modules,
  ...
}:
let
  monitor = import ./monitor.nix { inherit pkgs; };
in
{
  imports = [
    ./hardware-configuration.nix
    modules.hyprland
    ../../users/lsimek/user.nix
  ];

  # nix.settings.extra-substituters = [
  #   "http://victus.akita-bleak.ts.net?priority=50"
  # ];

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

  home-manager = {
    # also pass inputs to home-manager modules
    extraSpecialArgs = {
      inherit modules pkgs-unstable;
    };
    users = {
      lsimek = import ../../users/lsimek/home.nix;
    };

    backupFileExtension = "backup";
    useGlobalPkgs = true;
  };

  services.upower.enable = true;
  services.upower.percentageAction = 5;

  # virtualisation.libvirtd = {
  #   enable = true;
  #   qemu = {
  #     package = pkgs.qemu_kvm;
  #     runAsRoot = true;
  #     swtpm.enable = true;
  #     ovmf = {
  #       enable = true;
  #       packages = [
  #         (pkgs.OVMF.override {
  #           secureBoot = true;
  #           tpmSupport = true;
  #         }).fd
  #       ];
  #     };
  #   };
  # };

  # programs.virt-manager.enable = true;

  # virtualisation.spiceUSBRedirection.enable = true;

  # virtualisation.waydroid.enable = true;

  # users.extraGroups.vboxusers.members = [ "lsimek" ];

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

  services.redshift = {
    enable = true;
    brightness = {
      # Note the string values below.
      day = "1";
      night = "1";
    };
    temperature = {
      day = 5500;
      night = 3700;
    };
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

  # nixpkgs.config.packageOverrides = pkgs: {
  # intel-vaapi-driver = pkgs.intel-vaapi-driver.override { enableHybridCodec = true; };
  # };
  # options.hardware.intelgpu.driver = "xe";

  hardware.graphics = {
    enable = true;
    # extraPackages = with pkgs; [
    # intel-media-driver # LIBVA_DRIVER_NAME=iHD
    # intel-vaapi-driver # LIBVA_DRIVER_NAME=i965 (older but works better for Firefox/Chromium)
    # libvdpau-va-gl
    # ];
  };
  # environment.sessionVariables = {
  # LIBVA_DRIVER_NAME = "iHD";
  # }; # Force intel-media-driver

  system.stateVersion = "24.11";

}
