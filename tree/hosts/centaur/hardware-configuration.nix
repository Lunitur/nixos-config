{ ... }: {
  flake.modules.nixos.hosts.centaur.hardware = { config, lib, modulesPath, ... }: {
    imports =
      [
        (modulesPath + "/installer/scan/not-detected.nix")
      ];

    boot.initrd.availableKernelModules = [ "nvme" "xhci_pci" "ahci" "usb_storage" "usbhid" "sd_mod" ];
    boot.initrd.kernelModules = [ ];
    boot.kernelModules = [ "kvm-amd" ];
    boot.extraModulePackages = [ ];

    fileSystems."/" =
      {
        device = "/dev/disk/by-uuid/818c7743-bdc9-4723-a40a-a7bff9f24fe1";
        fsType = "btrfs";
        options = [ "subvol=@nixos/root" "compress=zstd" ];
      };

    fileSystems."/home" =
      {
        device = "/dev/disk/by-uuid/818c7743-bdc9-4723-a40a-a7bff9f24fe1";
        fsType = "btrfs";
        options = [ "subvol=@nixos/root" "compress=zstd" ];
      };

    fileSystems."/nix" =
      {
        device = "/dev/disk/by-uuid/818c7743-bdc9-4723-a40a-a7bff9f24fe1";
        fsType = "btrfs";
        options = [ "subvol=@nixos/nix" "compress=zstd" "noatime" ];
      };

    fileSystems."/boot" =
      {
        device = "/dev/disk/by-uuid/1CB8-5ECA";
        fsType = "vfat";
        options = [ "fmask=0022" "dmask=0022" ];
      };

    swapDevices = [ ];

    # Enables DHCP on each ethernet and wireless interface. In case of scripted networking
    # (the default) this is the recommended approach. When using systemd-networkd it's
    # still possible to use this option, but it's recommended to use it in conjunction
    # with explicit per-interface declarations with `networking.interfaces.<interface>.useDHCP`.
    networking.useDHCP = lib.mkDefault true;
    # networking.interfaces.enp10s0.useDHCP = lib.mkDefault true;
    # networking.interfaces.wlp9s0.useDHCP = lib.mkDefault true;

    nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
    hardware.cpu.amd.updateMicrocode = lib.mkDefault config.hardware.enableRedistributableFirmware;
  };
}
