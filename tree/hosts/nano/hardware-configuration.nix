{ ... }: {
  flake.modules.nixos.hosts.nano.hardware = { config, lib, modulesPath, ... }: {
    imports = [
      (modulesPath + "/profiles/qemu-guest.nix")
    ];

    boot.initrd.availableKernelModules = [
      "xhci_pci"
      "virtio_scsi"
      "sr_mod"
    ];
    boot.initrd.kernelModules = [ ];
    boot.kernelModules = [ ];
    boot.extraModulePackages = [ ];

    fileSystems."/" = {
      device = "/dev/disk/by-uuid/b640b662-03d5-4a43-a3bc-29d7c2b69dfc";
      fsType = "ext4";
    };

    fileSystems."/boot" = {
      device = "/dev/disk/by-uuid/9CE0-70B5";
      fsType = "vfat";
      options = [
        "fmask=0077"
        "dmask=0077"
      ];
    };

    networking.useDHCP = lib.mkDefault true;
    networking.interfaces.enp1s0.useDHCP = true;

    nixpkgs.hostPlatform = lib.mkDefault "aarch64-linux";
  };
}
