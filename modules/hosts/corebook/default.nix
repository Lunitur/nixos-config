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
        youtube-music
        vanilla-dmz
      ];

      programs.adb.enable = true;
      users.users.carjin.extraGroups = [ "adbusers" ];

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
            CPU_SCALING_GOVERNOR_ON_AC = "performance";
            CPU_SCALING_GOVERNOR_ON_BATTERY = "powersave";
            START_CHARGE_THRESH_BAT0 = 80;
            STOP_CHARGE_THRESH_BAT0 = 95;
            TLP_DEFAULT_MODE = "BAT";

            PLATFORM_PROFILE_ON_AC = "performance";
            PLATFORM_PROFILE_ON_BAT = "low-power";
            CPU_ENERGY_PERF_POLICY_ON_AC = "performance";
            CPU_ENERGY_PERF_POLICY_ON_BAT = "balance_power";
            CPU_HWP_DYN_BOOST_ON_AC = 1;
            CPU_HWP_DYN_BOOST_ON_BAT = 0;

            USB_AUTOSUSPEND = 0;
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

      services.logind.settings.Login.HandleLidSwitch = "hibernate";

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
