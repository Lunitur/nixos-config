{
  inputs,
  ...
}:
{
  flake.nixosModules.corebook =
    {
      config,
      lib,
      pkgs,
      ...
    }:
    {
      imports = [
        inputs.self.nixosModules.user-carjin
      ];

      programs.nix-index-database.comma.enable = true;

      programs.niri.enable = true;

      environment.systemPackages = with pkgs; [
        virtiofsd # libvirt folder sharing
        moonlight-qt
        tshark
        nikto
        pear-desktop
        vanilla-dmz
        android-tools
        pciutils
        powertop # Diagnostics only; TLP owns power tuning.
      ];

      users.users.carjin.extraGroups = [ "adbusers" ];

      services.upower.enable = true;

      services.postgresql = {
        enable = true;
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
        tlp = {
          enable = true;
          settings = {
            # intel_pstate's powersave governor still scales up under load.
            CPU_SCALING_GOVERNOR_ON_AC = "powersave";
            CPU_SCALING_GOVERNOR_ON_BAT = "powersave";
            START_CHARGE_THRESH_BAT0 = 80;
            STOP_CHARGE_THRESH_BAT0 = 95;
            # Always follow the power source, including after suspend/resume.
            TLP_AUTO_SWITCH = 1;
            TLP_PROFILE_DEFAULT = "BAL";

            PLATFORM_PROFILE_ON_AC = "performance";
            PLATFORM_PROFILE_ON_BAT = "low-power";
            CPU_ENERGY_PERF_POLICY_ON_AC = "balance_performance";
            CPU_ENERGY_PERF_POLICY_ON_BAT = "power";
            CPU_BOOST_ON_AC = 1;
            CPU_BOOST_ON_BAT = 0;
            CPU_HWP_DYN_BOOST_ON_AC = 1;
            CPU_HWP_DYN_BOOST_ON_BAT = 0;

            PCIE_ASPM_ON_BAT = "powersave";
            USB_AUTOSUSPEND = 1;
            # TLP excludes keyboards, mice, audio devices and printers by default.
          };
        };
      };

      virtualisation.podman = {
        enable = true;
        dockerCompat = true;
      };

      virtualisation.libvirtd = {
        enable = false;
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

      programs.virt-manager.enable = false;

      virtualisation.spiceUSBRedirection.enable = true;

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

      programs.steam = {
        enable = true;
        remotePlay.openFirewall = true; # Open ports in the firewall for Steam Remote Play
        dedicatedServer.openFirewall = true; # Open ports in the firewall for Source Dedicated Server
        localNetworkGameTransfers.openFirewall = true; # Open ports in the firewall for Steam Local Network Game Transfers
      };

      boot.initrd.systemd.enable = true;

      swapDevices = [ { device = "/var/swapfile"; } ];
      boot.resumeDevice = "/dev/disk/by-uuid/ef200b06-21a4-4383-b8fb-6bb845714809";
      boot.kernelParams = [ "resume_offset=1933233" ];

      services.logind.settings.Login = {
        HandleLidSwitch = "suspend-then-hibernate";
        HandleLidSwitchExternalPower = "suspend-then-hibernate";
      };

      systemd.sleep.settings.Sleep = {
        HibernateDelaySec = "2h";
      };

      boot.loader.systemd-boot.enable = true;
      boot.loader.efi.canTouchEfiVariables = true;

      boot.kernelPackages = pkgs.linuxPackages_zen;

      networking.hostName = "corebook";

      services.blueman.enable = true;
      hardware.bluetooth.enable = true;

      powerManagement = {
        enable = true;
        cpuFreqGovernor = "powersave";
        # Boot-time auto-tune races with TLP and ignores its device exclusions.
        powertop.enable = false;
      };

      home-manager.users.carjin.services.swayidle.timeouts = lib.mkForce [
        {
          timeout = 120;
          command = "${pkgs.brightnessctl}/bin/brightnessctl -s set 10%";
          resumeCommand = "${pkgs.brightnessctl}/bin/brightnessctl -r";
        }
        {
          timeout = 300;
          command = "${pkgs.systemd}/bin/loginctl lock-session";
        }
        {
          timeout = 330;
          command = "${lib.getExe pkgs.niri} msg action power-off-monitors";
          resumeCommand = "${lib.getExe pkgs.niri} msg action power-on-monitors";
        }
      ];

      hardware = {
        enableAllFirmware = true;
        acpilight.enable = true;
        keyboard.qmk.enable = true;
        keyboard.zsa.enable = true;

        graphics = {
          extraPackages = with pkgs; [
            intel-media-driver
            intel-compute-runtime

            libva-vdpau-driver
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

    };
}
