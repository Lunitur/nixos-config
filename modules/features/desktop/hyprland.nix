{ ... }:
{
  flake.nixosModules.hyprland =
    {
      config,
      lib,
      pkgs,
      ...
    }:
    {
      programs.hyprland.enable = true;
      programs.hyprland.withUWSM = true;
      programs.uwsm.enable = true;
    };
}
