{
  config,
  lib,
  ...
}:
let
  cfg = config.features.hardware.usb-tethering;
in
{
  options.features.hardware.usb-tethering.enable = lib.mkEnableOption "USB Tethering";

  config = lib.mkIf cfg.enable {
    boot.kernelModules = [
      "rndis_host"
      "cdc-ether"
    ];
  };
}