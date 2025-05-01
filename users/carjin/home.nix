{
  pkgs-unstable,
  modules,
  pkgs,
  lib,
  ...
}:
let

  tex = (
    pkgs.texlive.combine {
      inherit (pkgs.texlive)
        scheme-medium

        textpos
        etextools
        environ
        fmtcount
        koma-script
        # inputenc
        babel
        babel-croatian
        datetime
        geometry
        amsfonts
        # amsmath
        # amssymb
        # amsthm
        csquotes
        tcolorbox
        pgf
        pgfplots
        arydshln
        float
        xcolor
        # fontenc
        breqn
        thmtools
        multirow
        hyperref
        booktabs
        listings
        letltxmacro
        adjustbox
        enumitem
        biblatex
        # mathrsfs
        placeins
        mathtools
        autonum
        # bm
        url # dvisvgm
        # dvipng # for preview and export as html
        # wrapfig
        # amsmath
        # ulem
        # hyperref
        # capt-of
        ;
      #(setq org-latex-compiler "lualatex")
      #(setq org-preview-latex-default-process 'dvisvgm)
    }
  );
in
{

  imports = [
    modules.nushell
    # modules.stylix-hm
    # modules.ls-colors
    ./dotfiles.nix
    ./pueue.nix
    ./foot.nix
    ./zathura.nix
    ./conky.nix
    ./helix.nix
    ./git.nix
    ./zsh.nix
    ./udiskie.nix
    ./swaync.nix
    ./starship.nix
    ./rofi.nix
    ./kitty.nix
    ./fonts.nix
    ./hyprland
    ./waybar
    # ./stylix
    # ./theme
  ];

  home.username = "carjin";
  home.homeDirectory = "/home/carjin";

  home.stateVersion = "23.11";

  home.packages =
    (with pkgs-unstable; [
      tldr
      nmap
      ani-cli
      protonup-ng
    ])
    ++ (with pkgs; [
      mupdf
      bibtex-tidy
      texlab
      tex
      texmaker
      calibre
      firefox
      inkscape
      librewolf
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

      (rstudioWrapper.override {
        packages = with rPackages; [
          ggplot2
          dplyr
          xts
          tidyverse
        ];
      })
    ]);

  systemd.user.services.hyprpaper = {
    Unit = {
      After = [ "wayland-session-waitenv.service" ];
    };
  };

  systemd.user.services.hypridle = {
    Unit = {
      After = [ "wayland-session-waitenv.service" ];
    };
  };

  home.sessionVariables = {
    EDITOR = "hx";
  };
  # Let Home Manager install and manage itself.
  programs.home-manager.enable = true;

  dconf.enable = true;

  stylix.targets = {
    waybar.enable = false;
    hyprland.enable = false;
    hyprlock.enable = false;
    vscode.enable = false;
    wofi.enable = false;
  };
  # stylix.ls-colors.enable = true;

  # gtk.iconTheme = {
  #   package = pkgs.papirus-icon-theme;
  #   name = "Papirus";
  # };

  dconf.settings = {
    "org/virt-manager/virt-manager/connections" = {
      autoconnect = [ "qemu:///system" ];
      uris = [ "qemu:///system" ];
    }; # fix ui virt-manager bug
  };

}
