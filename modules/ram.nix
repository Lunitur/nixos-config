{
  boot.kernelSysctl = {
    # Delay flushing data to disk.
    # 60-80% of RAM can be dirty before blocking processes.
    "vm.dirty_ratio" = 80;

    # Start background writeback (asynchronous) when this threshold is met.
    # Keeps the disk idle for longer periods.
    "vm.dirty_background_ratio" = 50;

    # Decrease "swappiness" (0-100).
    # A value of 10 tells the kernel: "Prefer evicting page cache (files)
    # over swapping out application memory (anonymous pages) by a factor of 9:1 relative to default."
    "vm.swappiness" = 10;

    # VFS Cache Pressure (Default 100).
    # Controls the kernel's tendency to reclaim 'dentry' and 'inode' objects.
    # Lowering to 50 causes the kernel to retain filesystem metadata in RAM longer,
    # significantly speeding up file lookups (e.g., finding datasets, git status).
    "vm.vfs_cache_pressure" = 50;
  };

  boot.tmp = {
    useTmpfs = true;
    # If not set, defaults to 50% of RAM.
    # You can set it higher if you compile large projects (like kernels or heavy C++ libs).
    tmpfsSize = "75%";
  };

  boot.kernelParams = [ "transparent_hugepage=always" ];

  zramSwap = {
    enable = true;
    # Priority 100 ensures ZRAM is used before any disk-based swap partitions.
    priority = 100;
    # Percentage of RAM to use as swap *uncompressed*.
    # With high RAM, you can set this to 50-100.
    memoryPercent = 50;
    algorithm = "zstd"; # Better compression ratio than lz4, slightly higher CPU usage.
  };

  # fileSystems."/home/youruser/research/scratch" = {
  #   device = "tmpfs";
  #   fsType = "tmpfs";
  #   # limit size to prevent accidental RAM exhaustion
  #   options = [
  #     "size=16G"
  #     "mode=755"
  #     "nosuid"
  #     "nodev"
  #   ];
  # };
}
