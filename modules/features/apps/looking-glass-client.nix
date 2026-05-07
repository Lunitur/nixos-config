{ lib, ... }:
{
  flake.nixosModules.looking-glass-client =
    { pkgs, ... }:
    let
      fontPath = "${pkgs.dejavu_fonts}/share/fonts/truetype/DejaVuSansMono.ttf";

      pathed-lg = pkgs.looking-glass-client.overrideAttrs (oldAttrs: {
        buildInputs = oldAttrs.buildInputs ++ [ pkgs.dejavu_fonts ];

        postPatch = (oldAttrs.postPatch or "") + ''
          # Replace the fontconfig-based font lookup with a direct path.
          # Bypasses fontconfig entirely to avoid stale cache issues.
          #
          # 1. Change default uiFont in config.c
          substituteInPlace src/config.c \
            --replace-fail '"DejaVu Sans Mono"' \
                          '"${fontPath}"'

          # 2. Patch util_getUIFont to return the path directly when it starts with '/'
          substituteInPlace src/util.c \
            --replace-fail \
              'FcPattern * pat = FcNameParse((const FcChar8*) fontName);' \
              'if (fontName && fontName[0] == '"'"'/'"'"') { return strdup(fontName); } FcPattern * pat = FcNameParse((const FcChar8*) fontName);'
        '';

        postInstall = (oldAttrs.postInstall or "") + ''
          if ! test -f "${fontPath}"; then
            echo "ERROR: DejaVuSansMono.ttf not found at ${fontPath}!" >&2
            exit 1
          fi
        '';
      });
    in
    {
      environment.systemPackages = [ pathed-lg ];

      # Clear stale user fontconfig cache on rebuild
      system.activationScripts.looking-glass-fonts.text = ''
        rm -rf /home/carjin/.cache/fontconfig
      '';
    };
}
