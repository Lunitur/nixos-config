{ ... }:
{
  flake.homeModules.shell-scripts =
    {
      config,
      lib,
      pkgs,
      ...
    }:
    let
      # Define scripts here or import from underscore files
      screenshot = pkgs.writers.writeNuBin "screenshot" {
        makeWrapperArgs = with pkgs; [
          "--prefix PATH : ${
            lib.makeBinPath [
              libnotify
              slurp
              wayshot
              swappy
              wl-clipboard
            ]
          }"
        ];
      } (builtins.readFile ./screenshot.nu);

      lorem = pkgs.writers.writeNuBin "lorem" { } (builtins.readFile ./lorem.nu);

      blocks = pkgs.writers.writeNuBin "blocks" { } (builtins.readFile ./blocks.nu);
    in
    {
      home.packages = [
        # screenshot
        lorem
        # blocks
      ];
    };
}
