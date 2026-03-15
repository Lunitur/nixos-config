{
  pkgs,
  config,
  lib,
  ...
}:
let
  cfg = config.features.hardware.kmonad;
in

{
  options.features.hardware.kmonad.enable = lib.mkEnableOption "Enable kmonad";
  config = lib.mkIf cfg.enable {
    environment.systemPackages = [ pkgs.kmonad ];

    boot.kernelModules = [ "uinput" ];

    services.udev.extraRules = ''
      KERNEL=="uinput", SUBSYSTEM=="misc", TAG+="uaccess", OPTIONS+="static_node=uinput", GROUP="input", MODE="0660"
    '';
  };
}
