{ pkgs, pkgs-unstable, ... }:
{

  home.packages =
    (with pkgs-unstable; [
      tldr
      nmap
      ani-cli
      protonup-ng
    ])
    ++ (with pkgs; [
      pandoc
      lean4
      kdePackages.ghostwriter
      pgcli
      pcsx2
      ytmdl
      zulu
      gimp3
      vscode-langservers-extracted
      gemini-cli
      clojure
      clojure-lsp
      cljfmt
      cljstyle
      clj-kondo
      babashka
      leiningen
      heroic
      xfce.xfce4-taskmanager
      telegram-desktop
      vesktop
      signal-desktop
      element-desktop
      mupdf
      inkscape
      chromium
      nextcloud-client
      oterm
      mpv
      peazip
      lutris
      deluge-gtk
      osu-lazer-bin
      dconf
      anki-bin
      gedit
      libreoffice
      vscode-fhs
      thunderbird
      halloy
      kdePackages.kdenlive
      yt-dlp
      bemoji
      (rstudioWrapper.override {
        packages = with rPackages; [
          ggplot2
          dplyr
          xts
          tidyverse
        ];
      })
    ]);
}
