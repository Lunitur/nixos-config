{
  stdenv,
  kernel,
  kernelModuleMakeFlags,
}:
stdenv.mkDerivation {
  pname = "tas2783-px13";
  version = kernel.version;
  src = kernel.src;

  sourceRoot = "linux-${kernel.version}/sound/soc/codecs";
  patches = [ ./tas2783-px13-stereo.patch ];
  nativeBuildInputs = kernel.moduleBuildDependencies;
  hardeningDisable = [ "pic" ];

  postPatch = ''
    echo 'obj-m := snd-soc-tas2783-sdw.o
    snd-soc-tas2783-sdw-y := tas2783-sdw.o' > Makefile
  '';

  makeFlags = kernelModuleMakeFlags ++ [
    "-C"
    "${kernel.dev}/lib/modules/${kernel.modDirVersion}/build"
    "M=$(PWD)"
  ];
  buildFlags = [ "modules" ];
  installTargets = [ "modules_install" ];
  installFlags = [
    "INSTALL_MOD_PATH=${placeholder "out"}"
    "INSTALL_MOD_DIR=updates"
    "DEPMOD=true"
  ];
}
