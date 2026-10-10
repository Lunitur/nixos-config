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
      ...
    }:
    let
      multimonitor = import ../../../scripts/multimonitor.nix { inherit pkgs; };
    in
    {
      imports = [
        inputs.self.nixosModules.user-carjin
        inputs.self.nixosModules.looking-glass-client
      ];

      programs.nix-index-database.comma.enable = true;

      services.postgresql = {
        enable = true;
        authentication = pkgs.lib.mkOverride 10 ''
          #type database  DBuser  auth-method
          local all       all     trust
        '';
      };

      services = {
        upower.enable = true;

        tlp.enable = lib.mkForce false;

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

      # Keep logical CPU1 offline on AC and battery to avoid the hard freezes.
      systemd.services.disable-cpu1 = {
        description = "Disable CPU1 to prevent Victus freezes";
        wantedBy = [ "sysinit.target" ];
        after = [ "local-fs.target" ];
        before = [
          "sysinit.target"
          "auto-cpufreq.service"
        ];
        unitConfig.DefaultDependencies = false;
        serviceConfig = {
          Type = "oneshot";
          RemainAfterExit = true;
        };
        script = ''
          echo 0 > /sys/devices/system/cpu/cpu1/online
        '';
      };

      services.udev.extraRules = ''
        KERNEL=="hidraw*", SUBSYSTEM=="hidraw", ATTRS{serial}=="*vial:f64c2b3c*", MODE="0660", GROUP="users", TAG+="uaccess", TAG+="udev-acl"
        KERNEL=="hidraw*", SUBSYSTEM=="hidraw", MODE="0660", GROUP="users", TAG+="uaccess", TAG+="udev-acl"
      '';

      programs.niri.enable = true;

      environment.systemPackages = with pkgs; [
        multimonitor
        virtiofsd # libvirt folder sharing
        protonplus
        vial
        vanilla-dmz
        usbutils
        argyllcms
        gpu-win
        gpu-linux
        android-tools
        beyond-all-reason
        picocom
      ];

      systemd.tmpfiles.rules = [
        "L+ /usr/bin/umu-run - - - - /run/current-system/sw/bin/umu-run"
      ];

      boot.initrd.systemd.enable = true;

      networking.extraHosts = ''
        127.0.0.1 irc.local
      '';

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

      # programs.gamescope = {
      #   enable = true;
      #   env = {
      #     __NV_PRIME_RENDER_OFFLOAD = "1";
      #     __VK_LAYER_NV_optimus = "NVIDIA_only";
      #     __GLX_VENDOR_LIBRARY_NAME = "nvidia";
      #   };
      # };

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

      nix.settings.extra-sandbox-paths = [ "/var/cache/ccache" ];

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

      specialisation =
        let
          pstateTest = mode: {
            # nixos-hardware also adds amd_pstate=active. Replace every mode
            # argument while preserving the other inherited kernel parameters.
            boot.kernelParams = lib.mkForce (
              lib.filter (param: !(lib.hasPrefix "amd_pstate=" param)) config.boot.kernelParams
              ++ [ "amd_pstate=${mode}" ]
            );

            # With a generic governor, powersave holds the CPU at its minimum;
            # schedutil scales with load. auto-cpufreq skips EPP when unavailable.
            services.auto-cpufreq.settings.battery.governor = lib.mkForce "schedutil";
          };
        in
        {
          vfio.configuration = {
            vfio.enable = lib.mkForce true;
          };

          # Test without active EPP, retaining the normal performance-EPP entry.
          pstate-passive.configuration = pstateTest "passive";

          # If passive CPPC also freezes, test the legacy acpi-cpufreq driver.
          pstate-acpi.configuration = pstateTest "disable";
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

      services.moonshine = {
        enable = false;
        user = "carjin";
        firewallInterfaces = [
          "eno1"
          "wlp4s0"
        ];
        extraPackages = [
          config.programs.steam.package
          pkgs.coreutils
          pkgs.heroic
        ];
        environment = {
          # Keep the compositor, Vulkan Video encoder, and games on the RTX
          # 3050. The trailing `!` hides the AMD iGPU from Vulkan applications.
          MESA_VK_DEVICE_SELECT = "10de:25a2!";
          __GLX_VENDOR_LIBRARY_NAME = "nvidia";
          __NV_PRIME_RENDER_OFFLOAD = "1";
        };
        settings = {
          name = "victus";
          compositor.gpu = "10de:25a2";
          application = [
            {
              title = "Steam";
              command = [
                "steam"
                "steam://open/bigpicture"
              ];
            }
            {
              title = "Desktop";
              command = [
                "sleep"
                "infinity"
              ];
            }
            {
              title = "Heroic";
              command = [ "heroic" ];
            }
          ];
          application_scanner = [
            {
              type = "steam";
              library = "$HOME/.local/share/Steam";
              command = [
                "steam"
                "-bigpicture"
                "steam://rungameid/{game_id}"
              ];
            }
          ];
        };
      };

      services.blueman.enable = false;
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

      boot.binfmt.emulatedSystems = [ "aarch64-linux" ];
      boot.binfmt.preferStaticEmulators = true;

      boot.kernelPackages = pkgs.linuxPackages_xanmod_stable;
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
