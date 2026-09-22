{ ... }:
{
  flake.homeModules.desktop-packages =
    {
      pkgs,
      ...
    }:
    {
      home.packages = [
        pkgs.hashcards
      ]
      ++ (with pkgs; [
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
        vesktop
        signal-desktop
        element-desktop
        mupdf
        (pkgs.writeShellScriptBin "gemini-webapp" ''
          exec ${pkgs.chromium}/bin/chromium --app="https://gemini.google.com" "$@"
        '')
        nextcloud-client
        # lutris
        # deluge-gtk
        transmission_4-gtk
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
            ISLR2
            MASS
            languageserver
            gbm
            mgcv
            gamair
            qgam
            knitr
            rmarkdown
          ];
        })
        julia-bin
      ]);
    };
}
