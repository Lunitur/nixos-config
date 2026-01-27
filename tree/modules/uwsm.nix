{ ... }: {
  flake.modules.nixos.uwsm = {
    programs.hyprland.enable = true;
    programs.hyprland.withUWSM = true;
    programs.uwsm.enable = true;
  };
}
