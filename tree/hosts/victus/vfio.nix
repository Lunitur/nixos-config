{ ... }: {
  flake.modules.nixos.hosts.victus.vfio = { lib, config, ... }: 
  let
    # RTX 3070 Ti
    gpuIDs = [
      "10de:25a2" # Graphics
      "10de:2291" # Audio
    ];
  in
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
  };
}
