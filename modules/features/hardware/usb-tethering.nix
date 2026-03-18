{ ... }:
{
  flake.nixosModules.hardware-usb-tethering =
    {
      config,
      lib,
      ...
    }:
    {
      boot.kernelModules = [
        "rndis_host"
        "cdc-ether"
      ];
    };
}
