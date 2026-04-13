{
  inputs,
  ...
}:
{
  flake.nixosModules.victus =
    {
      config,
      lib,
      pkgs,
      pkgs-unstable,
      ...
    }:
    let
      multimonitor = import ../../../scripts/multimonitor.nix { inherit pkgs; };
    in
    {
      imports = [
        inputs.self.nixosModules.user-carjin
      ];

      programs.nix-index-database.comma.enable = true;

      services = {
        upower.enable = true;

        auto-cpufreq = {
          enable = true;
          settings = {
            charger = {
              governor = "performance";
              turbo = "always";
              energy_performance_preference = "performance";
              platform_profile = "performance";
            };

            battery = {
              governor = "powersave";
              turbo = "never";
              energy_performance_preference = "balance_power"; # Maximize battery life
              platform_profile = "low-power";
            };
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
        rpcs3
        vial
        vanilla-dmz
        usbutils
        argyllcms
        gpu-win
        gpu-linux
      ];

      systemd.tmpfiles.rules = [
        "L+ /usr/bin/umu-run - - - - /run/current-system/sw/bin/umu-run"
      ];

      boot.initrd.systemd.enable = true;

      networking.extraHosts = ''
        127.0.0.1 irc.local
      '';

      programs.adb.enable = true;
      users.users.carjin.extraGroups = [ "adbusers" ];

      services.printing.enable = true;
      services.printing.drivers = with pkgs; [
        mfcl3730cdnlpr
        mfcl3730cdncupswrapper
      ];

      services.colord.enable = true;

      environment.etc."color-profile.icm".source = ./color-profile-1.icm;

      environment.variables = {
        XCURSOR_THEME = "DMZ-Black"; # Match your theme's exact name
        XCURSOR_SIZE = "10";
      };

      environment.sessionVariables = {
        WLR_DRM_DEVICES = "/dev/dri/by-path/pci-0000:06:00.0-card:/dev/dri/by-path/pci-0000:01:00.0-card";
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

      virtualisation.spiceUSBRedirection.enable = true;

      specialisation = {
        vfio.configuration = {
          vfio.enable = lib.mkForce true;
        };
      };

      vfio.enable = false;

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

      boot.kernelPackages = pkgs-unstable.linuxPackages_xanmod_stable;
      boot.kernelParams = [
        "amd_iommu=on"
        "amd_pstate=active"
        "pci=noaer"
        "rtc_cmos.use_acpi_alarm=1"
      ]; # "amd_pstate=disable"

      # Enable kernel debug mode
      # boot.crashDump.enable = true;

      services.xserver.displayManager.setupCommands = "${multimonitor}/bin/multimonitor";

      networking.hostName = "victus"; # Define your hostname.

      systemd.targets.sleep.enable = false;
      systemd.targets.suspend.enable = false;
      systemd.targets.hybrid-sleep.enable = false;

      services.logind.settings.Login.HandleLidSwitch = "ignore";

      system.stateVersion = "23.11";

    };
}
