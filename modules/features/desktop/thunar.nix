{ ... }:
{
  flake.nixosModules.thunar =
    {
      config,
      lib,
      pkgs,
      ...
    }:
    {
      programs.thunar = {
        enable = true;
        plugins = with pkgs.xfce; [
          thunar-archive-plugin
          thunar-volman
        ];
      };
      services.gvfs.enable = true;
      services.tumbler.enable = true;
    };
}
