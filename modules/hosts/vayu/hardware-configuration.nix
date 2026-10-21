{ inputs, ... }:
{
  flake.nixosModules.vayu = {
    hardware.vayu = {
      enable = true;
      camera.enable = false;
      bootHardening.enable = true;
      usbGadget.enable = true;
      # Cross-build only the kernel; userspace keeps native aarch64 cache packages.
      kernel.package = inputs.vayu.packages.x86_64-linux.kernel;
    };

    boot.initrd.supportedFilesystems = [ "btrfs" ];

    fileSystems = {
      "/" = {
        device = "/dev/disk/by-label/nixos-btrfs";
        fsType = "btrfs";
        options = [
          "compress=zstd"
          "noatime"
          # Allow both UFS partitions of the multi-device root to appear.
          "x-systemd.device-timeout=120s"
        ];
      };
      "/boot" = {
        device = "/dev/disk/by-label/esp";
        fsType = "vfat";
      };
    };

    swapDevices = [ ];
  };
}
