{ ... }:
{
  flake.homeModules.heroic =
    {
      pkgs,
      ...
    }:
    let
      heroicUmuLauncher = pkgs.writeShellScriptBin "umu-run" ''
        unset GIO_EXTRA_MODULES

        if [ "$#" -eq 1 ] && [ "$1" = createprefix ]; then
          set -- 'C:\windows\system32\cmd.exe' /c exit 0
        fi

        exec ${pkgs.umu-launcher-unwrapped}/bin/umu-run "$@"
      '';

      heroic = pkgs.heroic.override {
        heroic-unwrapped = pkgs.heroic-unwrapped.override {
          umu-launcher = heroicUmuLauncher;
        };
      };
    in
    {
      home.packages = [
        pkgs.heroic
      ];
    };
}
