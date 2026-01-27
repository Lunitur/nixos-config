{ config, ... }: {
  flake.modules.nixos.hosts.victus.default = { pkgs, lib, config, ... }:
  let
    multimonitor = pkgs.writeShellScriptBin "multimonitor" ''
      #alias xrandr=${pkgs.xorg.xrandr}/bin/xrandr
      # Get the output of xrandr command
      output=$(${pkgs.xorg.xrandr}/bin/xrandr)
          
      # logname="multimonitor-$(date +%s)"
      # echo $output > "/home/carlos/$logname"

      # Check if the output contains "HDMI_1_0"
      if [[ $output == *"eDP-1-0"* ]]; then
        if [[ $output == *"HDMI-0 connected"* ]]; then
          # If yes set secondary monitor as primary
          ${pkgs.xorg.xrandr}/bin/xrandr --output HDMI-0 --primary --mode 1920x1080 -r 144 --output eDP-1-0 --mode 1920x1080 -r 144 --right-of HDMI-0
        elif [[ $output == *"HDMI-0 disconnected"* ]]; then
          ${pkgs.xorg.xrandr}/bin/xrandr --output eDP-1-0 --primary --mode 1920x1080 -r 144
        fi
      elif [[ $output == *"eDP"* ]]; then
        if [[ $output == *"HDMI-1-0 connected"* ]]; then
          # If yes set secondary monitor as primary
          ${pkgs.xorg.xrandr}/bin/xrandr --output HDMI-1-0 --primary --mode 1920x1080 -r 144 --output eDP --mode 1920x1080 -r 144 --right-of HDMI-1-0
        elif [[ $output == *"DisplayPort-1 connected"* ]]; then
          ${pkgs.xorg.xrandr}/bin/xrandr --output DisplayPort-1 --mode 1920x1080 -r 143.85 --primary --left-of eDP
        else
          ${pkgs.xorg.xrandr}/bin/xrandr --output eDP --primary --mode 1920x1080 -r 144
        fi
      fi
    '';
  in
  {
    imports = [
      config.flake.modules.nixos.hosts.victus.gputoggle
      config.flake.modules.nixos.hosts.victus.kvmfr
      config.flake.modules.nixos.hosts.victus.hardware
      config.flake.modules.nixos.hosts.victus.vfio
      config.flake.modules.nixos.anarhizam-org
      config.flake.modules.nixos.jupyter
      config.flake.modules.nixos.usb-tethering
      ../../../../users/carjin/user.nix
    ];

    services = {
      # upower.enable = true;

      tlp = {
        enable = true;
        settings = {
          # sudo tlp-stat to see current and possbile values

          # CPU_BOOST_ON_BAT = 0;
          CPU_SCALING_GOVERNOR_ON_BATTERY = "powersave";
          START_CHARGE_THRESH_BAT0 = 80;
          STOP_CHARGE_THRESH_BAT0 = 95;
          TLP_DEFAULT_MODE = "BAT";
          # Tell tlp to always run in default mode
          # TLP_PERSISTENT_DEFAULT = 1;

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

    services.udev.extraRules = ''
      KERNEL=="hidraw*", SUBSYSTEM=="hidraw", ATTRS{serial}=="*vial:f64c2b3c*", MODE="0660", GROUP="users", TAG+="uaccess", TAG+="udev-acl"
      KERNEL=="hidraw*", SUBSYSTEM=="hidraw", MODE="0660", GROUP="users", TAG+="uaccess", TAG+="udev-acl"
    '';

    programs.niri.enable = true;

    environment.systemPackages = with pkgs; [
      multimonitor
      virtiofsd # libvirt folder sharing
      looking-glass-client
      bottles
      protonplus
      heroic
      rpcs3
      vial
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
          # Session = "hyprland-uwsm.desktop";
          Session = "niri.desktop";
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
      };
    };

    programs.virt-manager.enable = true;

    specialisation = {
      vfio.configuration = {
        vfio.enable = lib.mkForce true;
      };
    };

    vfio.enable = false;

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
      powerManagement.finegrained = true;

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
      package = config.boot.kernelPackages.nvidiaPackages.stable; # config.boot.kernelPackages.nvidiaPackages.stable;

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

  };
}
