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
        (ani-cli.overrideAttrs (_: {
          src = pkgs.fetchFromGitHub {
            owner = "pystardust";
            repo = "ani-cli";
            tag = "v4.11";
            hash = "sha256-gQprGtKXXpDm66dFWsrriL4G0NPav+nqm8T6wkdbgk8=";
          };
        }))
        protonup-ng
        heroic
      ])
      ++ (with pkgs; [
        nodejs
        discord
        mangal
        mangayomi
        antigravity-fhs
        prismlauncher
        ytfzf
        pandoc
        moonlight-qt
        elan
        kdePackages.ghostwriter
        pgcli
        pcsx2
        ytmdl
        gimp3
        vscode-langservers-extracted
        clojure
        clojure-lsp
        cljfmt
        cljstyle
        clj-kondo
        babashka
        leiningen
        xfce.xfce4-taskmanager
        telegram-desktop
        vesktop
        signal-desktop
        element-desktop
        mupdf
        inkscape
        chromium
        (pkgs.writeShellScriptBin "gemini-webapp" ''
          exec ${pkgs.chromium}/bin/chromium --app="https://gemini.google.com" "$@"
        '')
        nextcloud-client
        oterm
        lutris
        hyprpicker
        deluge-gtk
        osu-lazer-bin
        dconf
        anki-bin
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
        vscode-fhs
        thunderbird
        halloy
        kdePackages.kdenlive
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
