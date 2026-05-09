{ ... }:
{
  flake.homeModules.desktop-packages =
    {
      pkgs,
      pkgs-unstable,
      ...
    }:
    {
      home.packages = [
        pkgs.hashcards
      ]
      ++ (with pkgs-unstable; [
        tlrc
        nmap
        (pkgs.ani-cli.overrideAttrs (old: {
          src = pkgs.fetchFromGitHub {
            owner = "pystardust";
            repo = "ani-cli";
            tag = "v4.14";
            hash = "sha256-OyCKDN89sBz59+3JncMDyNOq8UMqqjara+A0Owo3oko=";
          };
          nativeBuildInputs = (old.nativeBuildInputs or [ ]) ++ [ pkgs.makeWrapper ];
          postInstall = (old.postInstall or "") + ''
            wrapProgram $out/bin/ani-cli --prefix PATH : ${pkgs.openssl}/bin
          '';
        }))
        protonup-ng
        (pkgs.symlinkJoin {
          name = "heroic";
          paths = [ pkgs-unstable.heroic ];
          nativeBuildInputs = [ pkgs.makeWrapper ];
          postBuild = ''
            wrapProgram $out/bin/heroic \
              --unset GIO_EXTRA_MODULES
          '';
        })
        (pkgs.symlinkJoin {
          name = "umu-launcher-wrapped";
          paths = [ pkgs-unstable.umu-launcher ];
          nativeBuildInputs = [ pkgs.makeWrapper ];
          postBuild = ''
            wrapProgram $out/bin/umu-run \
              --unset GIO_EXTRA_MODULES
          '';
        })
      ])
      ++ (with pkgs; [
        nodejs
        discord
        prismlauncher
        ytfzf
        pandoc
        moonlight-qt
        pgcli
        ytmdl
        clojure
        clojure-lsp
        cljfmt
        cljstyle
        clj-kondo
        babashka
        leiningen
        xfce4-taskmanager
        telegram-desktop
        vesktop
        signal-desktop
        element-desktop
        mupdf
        (pkgs.writeShellScriptBin "gemini-webapp" ''
          exec ${pkgs.chromium}/bin/chromium --app="https://gemini.google.com" "$@"
        '')
        nextcloud-client
        # lutris
        deluge-gtk
        dconf
        gedit
        (pkgs.symlinkJoin {
          name = "libreoffice";
          paths = [ pkgs.libreoffice ];
          nativeBuildInputs = [ pkgs.makeWrapper ];
          postBuild = ''
            for bin in $out/bin/*; do
              wrapProgram "$bin" \
                --set SAL_USE_VCLPLUGIN gtk3 \
                --set GDK_BACKEND wayland \
                --set GTK_THEME Adwaita:light
            done
          '';
        })
        thunderbird
        halloy
        yt-dlp
        bemoji
        jq
        (rWrapper.override {
          packages = with rPackages; [
            ggplot2
            dplyr
            xts
            tidyverse
            Bolstad
            languageserver
          ];
        })
        julia-bin
      ]);
    };
}
