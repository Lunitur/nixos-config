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
    ../../users/carjin/user.nix
    ../../modules/jupyter.nix
  ];

  # nix.settings.extra-substituters = [
  #   "http://victus.akita-bleak.ts.net?priority=50"
  # ];

  environment.systemPackages =
    (with pkgs-unstable; [
      # jetbrains.idea-community-bin
    ])
    ++ (with pkgs; [
      # moonlight-qt
      # wireshark
      # tshark
      # nikto
      # logseq
      # youtube-music
    ]);

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

  virtualisation.waydroid.enable = true;

  # users.extraGroups.vboxusers.members = [ "carjin" ];

  services.xserver.enable = true;
  services.displayManager.sddm = {
    enable = true;
    wayland.enable = true;
    settings = {
      Autologin = {
        Session = "hyprland-uwsm.desktop";
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

  # swapDevices = [ { device = "/var/swapfile"; } ];
  boot.initrd.systemd.enable = true;
  services.logind.lidSwitch = "hibernate"; # "hybrid-sleep";

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

  system.stateVersion = "25.05";

}
