{
  stdenv,
  kernel,
  kernelModuleMakeFlags,
}:
stdenv.mkDerivation {
  pname = "amd-sfh-px13";
  version = kernel.version;
  src = kernel.src;

  sourceRoot = "linux-${kernel.version}/drivers/hid/amd-sfh-hid";
  patches = [ ./disable-sra.patch ];
  nativeBuildInputs = kernel.moduleBuildDependencies;
  hardeningDisable = [ "pic" ];

  makeFlags = kernelModuleMakeFlags ++ [
    "-C"
    "${kernel.dev}/lib/modules/${kernel.modDirVersion}/build"
    "M=$(PWD)"
    "CONFIG_AMD_SFH_HID=m"
  ];
  buildFlags = [ "modules" ];
  installTargets = [ "modules_install" ];
  installFlags = [
    "INSTALL_MOD_PATH=${placeholder "out"}"
    "INSTALL_MOD_DIR=updates"
    "DEPMOD=true"
  ];
}
