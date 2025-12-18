{ pkgs, pkgs-unstable, ... }:
let
  local-pkgs = import ../../packages { inherit pkgs; };
in
{

  home.packages =
    (with local-pkgs; [
      hashcards
    ])
    ++ (with pkgs-unstable; [
      tlrc
      nmap
      ani-cli
      protonup-ng
      heroic
    ])
    ++ (with pkgs; [
      ytfzf
      pandoc
      moonlight-qt
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
