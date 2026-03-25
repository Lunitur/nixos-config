{ ... }:
{
  flake.nixosModules.hardware-ram =
    {
      config,
      lib,
      ...
    }:
    {
      boot.kernel.sysctl = {
        "vm.dirty_ratio" = 80;
        "vm.dirty_background_ratio" = 50;
        "vm.swappiness" = 10;
        "vm.vfs_cache_pressure" = 50;
      };
      boot.tmp = {
        useTmpfs = false;
        tmpfsSize = "75%";
      };
      boot.kernelParams = [ "transparent_hugepage=always" ];
      zramSwap = {
        enable = true;
        priority = 100;
        memoryPercent = 50;
        algorithm = "zstd";
      };
    };
}
