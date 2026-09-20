{ ... }:
{
  flake.homeModules.heroic =
    {
      pkgs,
      pkgs-unstable,
      ...
    }:
    let
      heroicUmuLauncher = pkgs.writeShellScriptBin "umu-run" ''
        unset GIO_EXTRA_MODULES

        if [ "$#" -eq 1 ] && [ "$1" = createprefix ]; then
          set -- 'C:\windows\system32\cmd.exe' /c exit 0
        fi

        exec ${pkgs-unstable.umu-launcher-unwrapped}/bin/umu-run "$@"
      '';

      heroic = pkgs-unstable.heroic.override {
        heroic-unwrapped = pkgs-unstable.heroic-unwrapped.override {
          umu-launcher = heroicUmuLauncher;
        };
      };
    in
    {
      home.packages = [
        # (pkgs.symlinkJoin {
        #   name = "heroic";
        #   paths = [ heroic ];
        #   nativeBuildInputs = [ pkgs.makeWrapper ];
        #   postBuild = ''
        #     wrapProgram $out/bin/heroic \
        #       --unset GIO_EXTRA_MODULES
        #   '';
        # })
        # (pkgs.symlinkJoin {
        #   name = "umu-launcher-wrapped";
        #   paths = [ pkgs-unstable.umu-launcher ];
        #   nativeBuildInputs = [ pkgs.makeWrapper ];
        #   postBuild = ''
        #     wrapProgram $out/bin/umu-run \
        #       --unset GIO_EXTRA_MODULES
        #   '';
        # })
        pkgs.heroic
      ];
    };
}
