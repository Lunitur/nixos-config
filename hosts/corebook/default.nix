{
  config,
  lib,
  pkgs,
  pkgs-unstable,
  inputs,
  ...
}:
let
  monitor = import ./monitor.nix { inherit pkgs; };
  user-pkgs = import ../../packages { inherit pkgs; };
in
{
  imports = [
    ./hardware-configuration.nix
    ../../users/carjin/user.nix
  ];

  services.mysql.enable = true;
  services.mysql.package = pkgs.mariadb;

  programs.niri.enable = true;

  environment.systemPackages = with pkgs; [
    virtiofsd # libvirt folder sharing
    moonlight-qt
    # wireshark
    tshark
    nikto
    logseq
    youtube-music
    kdePackages.ghostwriter
    vanilla-dmz
  ];

  services.postgresql = {
    enable = true;
    # ensureDatabases = [ "mydb" ];
    authentication = pkgs.lib.mkOverride 10 ''
      #type database  DBuser  auth-method
      local all       all     trust
    '';
  };

  environment.variables = {
    XCURSOR_THEME = "DMZ-Black"; # Match your theme's exact name
    XCURSOR_SIZE = "10";
  };

  services.printing.enable = true;
  services.printing.drivers = with pkgs; [
    mfcl3730cdnlpr
    mfcl3730cdncupswrapper
  ];

  services = {
    # upower.enable = true;

    tlp = {
      enable = true;
      settings = {
        # https://discourse.nixos.org/t/nixos-power-management-help-usb-doesnt-work/9933/2
        # sudo tlp-stat to see current and possbile values

        # CPU_BOOST_ON_BAT = 0;
        CPU_SCALING_GOVERNOR_ON_BATTERY = "powersave";
        START_CHARGE_THRESH_BAT0 = 80;
        STOP_CHARGE_THRESH_BAT0 = 95;
        TLP_DEFAULT_MODE = "BAT";
        # Tell tlp to always run in default mode
        # TLP_PERSISTENT_DEFAULT = 1;
        # INTEL_GPU_MIN_FREQ_ON_AC = 500;
        # INTEL_GPU_MIN_FREQ_ON_BAT = 500;

        PLATFORM_PROFILE_ON_AC = "balanced";
        PLATFORM_PROFILE_ON_BAT = "low-power";
        CPU_ENERGY_PERF_POLICY_ON_AC = "balance_performance";
        CPU_ENERGY_PERF_POLICY_ON_BAT = "balance_power";
        CPU_HWP_DYN_BOOST_ON_AC = 1;
        CPU_HWP_DYN_BOOST_ON_BAT = 0;

        # Don't autosuspend USB devices (Dell Monitor -> Input Devices)
        USB_AUTOSUSPEND = 0;
        # USB_EXCLUDE_WWAN = 1;
        # USB_DENYLIST = "3434:0820 046d:c548"; # Keychron Q2 Max + Logitech Bolt Receiver
      };
    };
  };

  # services.upower.enable = true;
  # services.upower.percentageAction = 5;

  virtualisation.libvirtd = {
    enable = true;
    qemu = {
      package = pkgs.qemu_kvm;
      runAsRoot = true;
      swtpm.enable = true;
      ovmf = {
        enable = true;
        packages = [
          (pkgs.OVMF.override {
            secureBoot = true;
            tpmSupport = true;
          }).fd
        ];
      };
    };
  };

  programs.virt-manager.enable = true;

  virtualisation.spiceUSBRedirection.enable = true;

  virtualisation.waydroid.enable = true;

  users.extraGroups.vboxusers.members = [ "carjin" ];

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

  # services.displayManager.cosmic-greeter.enable = true;
  # services.desktopManager.cosmic.enable = true;

  # programs.wireshark.enable = true;

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

  networking.hostName = "corebook";

  services.blueman.enable = true;
  hardware.bluetooth.enable = true;

  powerManagement = {
    enable = true;
    powertop.enable = true;
  };

  hardware = {
    enableAllFirmware = true;
    acpilight.enable = true;
    keyboard.qmk.enable = true;
    keyboard.zsa.enable = true;

    graphics = {
      extraPackages = with pkgs; [
        intel-media-driver
        intel-compute-runtime

        vaapiVdpau
        libvdpau-va-gl
      ];
    };

    enableRedistributableFirmware = true;
    cpu.intel.updateMicrocode = true;
  };

  environment.sessionVariables = {
    LIBVA_DRIVER_NAME = "iHD";
  }; # Force intel-media-driver

  system.stateVersion = "24.05";

}
