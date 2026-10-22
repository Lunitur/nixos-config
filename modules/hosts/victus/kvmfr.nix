{
  flake.nixosModules.kvmfr =
    { config, ... }:
    let
      kernel = config.boot.kernelPackages.kernel;
    in
    {
      boot.extraModulePackages = [
        (config.boot.kernelPackages.kvmfr.overrideAttrs (_: {
          # Kbuild installation also generates the module signing certificate.
          installPhase = null;
          installTargets = [ "modules_install" ];
          installFlags = [
            "-C"
            "${kernel.dev}/lib/modules/${kernel.modDirVersion}/build"
            "M=$(PWD)"
            "INSTALL_MOD_PATH=${placeholder "out"}"
            "INSTALL_MOD_DIR=kernel/drivers/misc"
            "DEPMOD=true"
          ];
        }))
      ];
      boot.kernelModules = [ "kvmfr" ];

      services.udev.extraRules = ''
        SUBSYSTEM=="kvmfr", OWNER="carjin", GROUP="kvm", MODE="0660", TAG+="uaccess"
        KERNEL=="kvmfr0", OWNER="carjin", GROUP="kvm", MODE="0660", TAG+="uaccess"
      '';

      virtualisation.libvirtd.qemu.verbatimConfig = ''
        cgroup_device_acl = [
            "/dev/null", "/dev/full", "/dev/zero",
            "/dev/random", "/dev/urandom",
            "/dev/ptmx", "/dev/kvm",
            "/dev/kvmfr0"
        ]
      '';

      boot.extraModprobeConfig = ''
        options kvmfr static_size_mb=32
      '';
    };
}
