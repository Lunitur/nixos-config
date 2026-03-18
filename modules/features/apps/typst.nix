{ ... }:
{
  flake.homeModules.typst =
    {
      config,
      lib,
      pkgs,
      ...
    }:
    {
      home.packages = with pkgs; [
        typst
        tinymist
        typstyle
      ];
    };
}
