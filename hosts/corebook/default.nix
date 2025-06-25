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

  # nix.settings.extra-substituters = [
  #   "http://victus.akita-bleak.ts.net?priority=50"
  # ];

  services.mysql.enable = true;
  services.mysql.package = pkgs.mariadb;

  programs.niri.enable = true;

  environment.systemPackages =
    (with pkgs-unstable; [
      jetbrains.idea-community-bin
    ])
    ++ (with pkgs; [
      virtiofsd # libvirt folder sharing
      moonlight-qt
      # wireshark
      tshark
      nikto
      logseq
      youtube-music
      kdePackages.ghostwriter
      vanilla-dmz
    ]);

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
  # boot.blacklistedKernelModules = [
  #   "i915"
  #   # "snd_pcsp"
  # ];

  # boot.kernelParams = [
  #   "module_blacklist=i915"
  # ];

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

  home-manager = {
    # also pass inputs to home-manager modules
    extraSpecialArgs = {
      inherit pkgs-unstable;
    };
    users = {
      carjin = import ../../users/carjin/home.nix;
    };

    backupFileExtension = "backup";
    useGlobalPkgs = true;
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

  # nixpkgs.config.packageOverrides = pkgs: {
  # intel-vaapi-driver = pkgs.intel-vaapi-driver.override { enableHybridCodec = true; };
  # };
  # options.hardware.intelgpu.driver = "xe";

  hardware = {
    enableAllFirmware = true;
    acpilight.enable = true;
    keyboard.qmk.enable = true;
    keyboard.zsa.enable = true;

    # Intel Hardware Acceleration
    # graphics = {
    #   enable = true;
    #   enable32Bit = true;
    #   package = unstablePkgs.mesa.drivers;
    #   package32 = unstablePkgs.pkgsi686Linux.mesa.drivers;
    #   extraPackages = with unstablePkgs; [
    #     intel-media-driver
    #     intel-compute-runtime
    #
    #     vaapiVdpau
    #     libvdpau-va-gl
    #   ];
    # };
    graphics = {
      # package =
      #   inputs.hyprland.inputs.nixpkgs.legacyPackages.${pkgs.stdenv.hostPlatform.system}.mesa.drivers;
      # package32 =
      #   inputs.hyprland.inputs.nixpkgs.legacyPackages.${pkgs.stdenv.hostPlatform.system}.pkgsi686Linux.mesa.drivers;
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

  # hardware.graphics = {
  #   enable = true;
  #   extraPackages = with pkgs; [
  #     vaapiIntel
  #     intel-media-driver
  #   ];
  #   # extraPackages = with pkgs; [
  #   # intel-media-driver # LIBVA_DRIVER_NAME=iHD
  #   # intel-vaapi-driver # LIBVA_DRIVER_NAME=i965 (older but works better for Firefox/Chromium)
  #   # libvdpau-va-gl
  #   # ];
  # };
  environment.sessionVariables = {
    LIBVA_DRIVER_NAME = "iHD";
  }; # Force intel-media-driver

  system.stateVersion = "24.05";

}
