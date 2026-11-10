{ inputs, ... }:
{
  flake.nixosModules.cerberus =
    { pkgs, ... }:
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

      hardware.bluetooth.enable = true;
      services.blueman.enable = true;

      boot.loader.systemd-boot.enable = true;
      boot.loader.efi.canTouchEfiVariables = true;

      networking.hostName = "cerberus";

      system.stateVersion = "26.05";
    };
}
