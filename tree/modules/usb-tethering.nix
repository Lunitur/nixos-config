{ ... }: {
  flake.modules.nixos.usb-tethering = {
    boot.kernelModules = [
      "rndis_host"
      "cdc-ether"
    ];
  };
}
