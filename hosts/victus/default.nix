{
  config,
  lib,
  pkgs,
  inputs,
  modules,
  pkgs-unstable,
  ...
}:
let
  multimonitor = import ./multimonitor.nix { inherit pkgs; };
  inherit (pkgs.stdenv.hostPlatform) system;
  umu = inputs.umu.packages.${system}.umu-launcher;
in
{
  imports = [
    ./gputoggle.nix
    ./hardware-configuration.nix
    ./vfio.nix
    ./kvmfr.nix
    ../../users/carjin/user.nix
    ../../modules/usb-tethering.nix
  ];

  nixpkgs.overlays = [ (import ../../overlays/lutris.nix pkgs-unstable) ];

  services.udev.extraRules = ''
    KERNEL=="hidraw*", SUBSYSTEM=="hidraw", ATTRS{serial}=="*vial:f64c2b3c*", MODE="0660", GROUP="users", TAG+="uaccess", TAG+="udev-acl"
    KERNEL=="hidraw*", SUBSYSTEM=="hidraw", MODE="0660", GROUP="users", TAG+="uaccess", TAG+="udev-acl"
  '';

  environment.systemPackages = with pkgs; [
    multimonitor
    virtiofsd # libvirt folder sharing
    looking-glass-client
    bottles
    protonplus
    heroic
    rpcs3
    kdePackages.ghostwriter
    vial
    umu
    vanilla-dmz
    usbutils
  ];

  boot.initrd.systemd.enable = true;

  programs.adb.enable = true;
  users.users.carjin.extraGroups = [ "adbusers" ];

  services.printing.enable = true;
  services.printing.drivers = with pkgs; [
    mfcl3730cdnlpr
    mfcl3730cdncupswrapper
  ];

  environment.variables = {
    XCURSOR_THEME = "DMZ-Black"; # Match your theme's exact name
    XCURSOR_SIZE = "10";
  };

  programs.gamescope = {
    enable = true;
    env = {
      __NV_PRIME_RENDER_OFFLOAD = "1";
      __VK_LAYER_NV_optimus = "NVIDIA_only";
      __GLX_VENDOR_LIBRARY_NAME = "nvidia";
    };
  };

  virtualisation.docker = {
    storageDriver = "btrfs";
    rootless = {
      enable = true;
      setSocketVariable = true;
    };
  };

  services.nix-serve = {
    enable = true;
    secretKeyFile = "/etc/private/cache-priv-key.pem";
  };

  services.nginx = {
    enable = true;
    recommendedProxySettings = true;
    virtualHosts = {
      "victus.akita-bleak.ts.net" = {
        locations."/".proxyPass =
          "http://${config.services.nix-serve.bindAddress}:${toString config.services.nix-serve.port}";
      };
    };
  };

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

  vfio.enable = true;

  boot.blacklistedKernelModules = [
    "nvidia"
    "nouveau"
  ];

  # specialisation.no-vfio.configuration = {
  #   vfio.enable = lib.mkForce false;
  services.xserver.videoDrivers = [ "nvidia" ];

  hardware.nvidia = {

    forceFullCompositionPipeline = true;

    # Modesetting is required.
    modesetting.enable = true;

    # Nvidia power management. Experimental, and can cause sleep/suspend to fail.
    # Enable this if you have graphical corruption issues or application crashes after waking
    # up from sleep. This fixes it by saving the entire VRAM memory to /tmp/ instead
    # of just the bare essentials.
    powerManagement.enable = true;

    # Fine-grained power management. Turns off GPU when not in use.
    # Experimental and only works on modern Nvidia GPUs (Turing or newer).
    powerManagement.finegrained = false;

    # Use the NVidia open source kernel module (not to be confused with the
    # independent third-party "nouveau" open source driver).
    # Support is limited to the Turing and later architectures. Full list of
    # supported GPUs is at:
    # https://github.com/NVIDIA/open-gpu-kernel-modules#compatible-gpus
    # Only available from driver 515.43.04+
    # Currently alpha-quality/buggy, so false is currently the recommended setting.
    open = false;

    # Enable the Nvidia settings menu,
    # accessible via `nvidia-settings`.
    nvidiaSettings = true;

    # Optionally, you may need to select the appropriate driver version for your specific GPU.
    package = config.boot.kernelPackages.nvidiaPackages.beta; # config.boot.kernelPackages.nvidiaPackages.stable;

    prime = {
      offload = {
        enable = true;
        enableOffloadCmd = true;
      };

      amdgpuBusId = "PCI:7:0:0";
      nvidiaBusId = "PCI:1:0:0";
    };
  };

  # };

  boot.supportedFilesystems = [ "ntfs" ];

  programs.sway.extraOptions = [ "--unsupported-gpu" ];

  powerManagement = {
    enable = true;
    # powertop.enable = true;
  };

  programs.steam = {
    enable = true;
    remotePlay.openFirewall = true; # Open ports in the firewall for Steam Remote Play
    dedicatedServer.openFirewall = true; # Open ports in the firewall for Source Dedicated Server
    localNetworkGameTransfers.openFirewall = true; # Open ports in the firewall for Steam Local Network Game Transfers
  };

  services.blueman.enable = true;
  hardware.bluetooth.enable = true;

  hardware.graphics = {
    enable = true;
    enable32Bit = true;
  };

  boot.loader = {
    efi = {
      canTouchEfiVariables = true;
      efiSysMountPoint = "/boot/efi";
    };
    grub = {
      efiSupport = true;
      useOSProber = true;
      device = "nodev";
    };
  };

  boot.kernelPackages = pkgs.linuxPackages_xanmod;
  boot.kernelParams = [
    "amd_iommu=on"
    "acpi_osi=Linux"
  ]; # "amd_pstate=disable"

  # Enable kernel debug mode
  # boot.crashDump.enable = true;

  services.xserver.displayManager.setupCommands = "${multimonitor}/bin/multimonitor";

  networking.hostName = "victus"; # Define your hostname.

  system.stateVersion = "23.11";

}
