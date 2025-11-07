let
  # RTX 3070 Ti
  gpuIDs = [
    "10de:25a2" # Graphics
    "10de:2291" # Audio
  ];
in
{
  pkgs,
  lib,
  config,
  ...
}:
{
  options.vfio.enable = with lib; mkEnableOption "Configure the machine for VFIO";

  config =
    let
      cfg = config.vfio;
    in
    {
      boot = {
        initrd.kernelModules = [
          "vfio_pci"
          "vfio"
          "vfio_iommu_type1"

          #   "nvidia"
          #   "nvidia_modeset"
          #   "nvidia_uvm"
          #   "nvidia_drm"
        ];

        blacklistedKernelModules = lib.optionals cfg.enable [
          "nvidia"
          "nouveau"
        ];

        kernelParams = [
          # enable IOMMU
          "amd_iommu=on"
        ]
        ++
          lib.optional cfg.enable
            # isolate the GPU
            ("vfio-pci.ids=" + lib.concatStringsSep "," gpuIDs);
      };

      virtualisation.spiceUSBRedirection.enable = true;
    };
}

# https://alexbakker.me/post/nixos-pci-passthrough-qemu-vfio.html
# https://astrid.tech/2022/09/22/0/nixos-gpu-vfio/
