{ inputs, ... }:
{
  flake.nixosModules.cerberus =
    {
      config,
      lib,
      pkgs,
      ...
    }:
    {
      imports = [
        inputs.self.nixosModules.user-carjin
        inputs.self.nixosModules.jupyter
      ];

      environment.systemPackages = with pkgs; [
        btrfs-progs
        moonlight-qt
        wireshark
        tshark
        nikto
        firefox
        kdePackages.ghostwriter
        jetbrains.pycharm
      ];

      home-manager.users.carjin = {
        home.packages = [ pkgs.sshfs ];

        # The private key stays in ~/.ssh/victus-downloads, outside the Nix store.
        systemd.user.services.victus-downloads = {
          Unit = {
            Description = "Victus Downloads via SSHFS";
            StartLimitIntervalSec = 0;
          };
          Service = {
            Type = "exec";
            Environment = "PATH=/run/wrappers/bin:${pkgs.openssh}/bin";
            ExecStartPre = "${pkgs.coreutils}/bin/mkdir -p %h/mnt/victus-downloads";
            ExecStart = lib.concatStringsSep " " [
              "${pkgs.sshfs}/bin/sshfs -f -F /dev/null"
              "carjin@victus.netbird.selfhosted:/home/carjin/Downloads %h/mnt/victus-downloads"
              "-o IdentityFile=%h/.ssh/victus-downloads,IdentitiesOnly=yes,IdentityAgent=none,BatchMode=yes"
              "-o StrictHostKeyChecking=yes,UserKnownHostsFile=%h/.ssh/known_hosts"
              "-o delay_connect,reconnect,ServerAliveInterval=15,ServerAliveCountMax=3,ConnectTimeout=10,idmap=user"
            ];
            ExecStop = "/run/wrappers/bin/fusermount3 -u %h/mnt/victus-downloads";
            ExecStopPost = "-/run/wrappers/bin/fusermount3 -uz %h/mnt/victus-downloads";
            Restart = "always";
            RestartSec = 15;
            TimeoutStopSec = 15;
          };
          Install.WantedBy = [ "default.target" ];
        };
      };

      programs.niri.enable = true;

      nixpkgs.overlays = [
        (final: prev: {
          niri = inputs.self.packages.${prev.stdenv.hostPlatform.system}.niri-cerberus;
        })
      ];

      services.xserver.enable = true;
      services.displayManager.sddm = {
        enable = true;
        wayland.enable = true;
        settings.Autologin = {
          Session = "niri.desktop";
          User = "carjin";
        };
      };

      programs.wireshark.enable = true;

      programs.steam = {
        enable = true;
        remotePlay.openFirewall = true;
        localNetworkGameTransfers.openFirewall = true;
      };

      services.upower = {
        enable = true;
        percentageAction = 5;
      };
      services.libinput.enable = true;

      powerManagement = {
        enable = true;
        powertop.enable = true;
      };

      services.logind.settings.Login = {
        HandleLidSwitch = "suspend";
        HandleLidSwitchExternalPower = "suspend";
      };

      systemd.sleep.settings.Sleep = {
        AllowSuspend = true;
        AllowHibernation = false;
        AllowHybridSleep = false;
        AllowSuspendThenHibernate = false;
      };

      hardware.bluetooth.enable = true;
      services.blueman.enable = true;

      # Keep SFH power management, but do not activate firmware posture sensing.
      boot.extraModulePackages = [
        (config.boot.kernelPackages.callPackage ./_tablet-mode/amd-sfh.nix { })
      ];
      boot.kernelParams = [ "module_blacklist=amd_sfh_tabletmode" ];

      boot.loader.systemd-boot.enable = true;
      boot.loader.efi.canTouchEfiVariables = true;

      networking.hostName = "cerberus";

      system.stateVersion = "26.05";
    };
}
