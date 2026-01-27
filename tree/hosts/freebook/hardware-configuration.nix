{ ... }: {
  flake.modules.nixos.hosts.freebook.hardware = { config, lib, modulesPath, ... }: {
    imports = [
      (modulesPath + "/installer/scan/not-detected.nix")
    ];

    boot.initrd.availableKernelModules = [
      "xhci_pci"
      "nvme"
      "usb_storage"
      "sd_mod"
      "sdhci_pci"
    ];
    boot.initrd.kernelModules = [ ];
    boot.kernelModules = [ "kvm-intel" ];
    boot.extraModulePackages = [ ];

    fileSystems."/" = {
      device = "/dev/disk/by-uuid/ae913da1-5d53-47fb-ac19-609aca27f54c";
      fsType = "btrfs";
      options = [
        "noatime"
        "compress=zstd"
        "subvol=@nixos/root"
      ];
    };

    fileSystems."/home" = {
      device = "/dev/disk/by-uuid/ae913da1-5d53-47fb-ac19-609aca27f54c";
      fsType = "btrfs";
      options = [
        "noatime"
        "compress=zstd"
        "subvol=@nixos/home"
      ];
    };

    fileSystems."/nix" = {
      device = "/dev/disk/by-uuid/ae913da1-5d53-47fb-ac19-609aca27f54c";
      fsType = "btrfs";
      options = [
        "compress=zstd"
        "noatime"
        "subvol=@nixos/nix"
      ];
    };

    fileSystems."/boot" = {
      device = "/dev/disk/by-uuid/DEFC-BB20";
      fsType = "vfat";
      options = [
        "fmask=0022"
        "dmask=0022"
      ];
    };

    swapDevices = [ ];

    networking.useDHCP = lib.mkDefault true;

    nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
    hardware.cpu.intel.updateMicrocode = lib.mkDefault config.hardware.enableRedistributableFirmware;
  };
}
