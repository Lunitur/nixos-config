{ ... }: {
  flake.modules.nixos.kmonad = { pkgs, ... }: {
    environment.systemPackages = [ pkgs.kmonad ];
    boot.kernelModules = [ "uinput" ];
    services.udev.extraRules = ''
      KERNEL=="uinput", SUBSYSTEM=="misc", TAG+="uaccess", OPTIONS+="static_node=uinput", GROUP="input", MODE="0660"
    '';
  };
}
