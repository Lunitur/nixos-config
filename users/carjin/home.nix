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
        scheme-full
        dvisvgm
        dvipng # for preview and export as html
        wrapfig
        amsmath
        ulem
        hyperref
        capt-of
        ;
      #(setq org-latex-compiler "lualatex")
      #(setq org-preview-latex-default-process 'dvisvgm)
    }
  );
in
{

  imports = [
    modules.nushell
    modules.stylix-hm
    modules.ls-colors
    ./dotfiles.nix
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

  programs.zathura = {
    enable = true;
    package = pkgs.zathura.override { useMupdf = true; };
  };

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

  services.conky = {
    enable = true;

  };

  services.hyprpaper = {
    enable = true;
    settings = {
      ipc = "on";
      # splash = false;
      # splash_offset = 2.0;

      # preload = [
      #   "Pictures/desktop.jpg"
      # ];

      # wallpaper = [
      #   "DP-1,Pictures/desktop.jpg"
      #   "DP-2,Pictures/desktop.jpg"
      # ];
    };
  };

  services.mako = {
    enable = true;
    anchor = "bottom-right";
    # font = "monospace 10";
    # backgroundColor = "#000000";
    # textColor = "#ff0000";
    width = 350;
    margin = "0,20,20";
    # padding = 10;
    borderSize = 1;
    # borderColor = "#7DDA58";
    borderRadius = 5;
    defaultTimeout = 10000;
    groupBy = "summary";
    icons = true;
  };

  home.sessionVariables = {
    EDITOR = "hx";
  };
  # Let Home Manager install and manage itself.
  programs.home-manager.enable = true;

  services.pueue = {
    enable = true;
    settings = {
      daemon = {
        default_parallel_tasks = 64;
      };
    };
  };

  programs.git = {
    enable = true;
    userEmail = "karlo.puselj@gmail.com";
    userName = "Lunitur";
    extraConfig = {
      receive.denyCurrentBranch = "warn";
    };
  };

  dconf.enable = true;
  programs.alacritty.enable = true;

  programs.helix = {
    enable = true;
    languages = {
      language-server.metals.config.metals = {
        autoImportBuild = "all";
      };

      language-server.texlab.config.texlab = {
        build = {
          onSave = true;
        };
        forwardSearch = {
          executable = "zathura";

          args = [
            "--synctex-forward"
            "%l:1:%f"
            "%p"
          ];
        };
        chktex.onEdit = true;
      };
      language = [
        {
          name = "latex";
          auto-format = true;
          # config.texlab.build.onSave = true;

        }
        {
          name = "nix";
          auto-format = true;
          formatter.command = "${pkgs.nixfmt-rfc-style}/bin/nixfmt";
        }
        {
          name = "haskell";
          file-types = [
            "hs"
            "lhs"
          ];
          auto-format = true;
          formatter.command = "${pkgs.haskellPackages.ormolu}/bin/ormolu";
          # linter.command = "${pkgs.haskellPackages.hlint}/bin/hlint";
        }
        {
          name = "scala";
          auto-format = true;
          # formatter.command = "${pkgs.scalafmt}/bin/scalafmt";
        }
      ];
    };
    settings = {
      theme = lib.mkForce "tokyonight";
      editor.lsp = {
        display-inlay-hints = true;
      };
      editor.soft-wrap.enable = true;
    };
    themes = {
      autumn_night_transparent = {
        "inherits" = "autumn_night";
        "ui.background" = { };
      };
    };
  };

  programs.foot = {
    enable = true;
    server.enable = true;
    settings = {
      colors = {
        # alpha = lib.mkForce 1;
        # background = "#E8E8E8";
      };
    };
  };

  wayland.windowManager.hyprland = {
    enable = true;
    systemd.enable = false;
    settings = {
      source = "carjin.conf";
    };
  };

  programs.hyprlock = {
    enable = true;
    settings = {
      general = {
        disable_loading_bar = true;
        # grace = 300;
        hide_cursor = true;
        # no_fade_in = false;
      };
    };
    extraConfig = ''
      background {
          path = screenshot
          blur_passes = 2
          blur_size = 8
          }'';
  };

  services.hypridle = {
    enable = true;
    settings = {
      general = {
        lock_cmd = "pidof hyprlock || hyprlock"; # avoid starting multiple hyprlock instances.
        before_sleep_cmd = "loginctl lock-session "; # lock before suspend.
        after_sleep_cmd = "hyprctl dispatch dpms on"; # to avoid having to press a key twice to turn on the display.
      };

      listener = [
        {
          timeout = 150; # 2.5min.
          on-timeout = "brightnessctl -s set 10"; # set monitor backlight to minimum, avoid 0 on OLED monitor.
          on-resume = "brightnessctl -r "; # monitor backlight restore.
        }

        # turn off keyboard backlight, comment out this section if you dont have a keyboard backlight.
        {
          timeout = 150; # 2.5min.
          on-timeout = "brightnessctl -sd rgb:kbd_backlight set 0 "; # turn off keyboard backlight.
          on-resume = "brightnessctl -rd rgb:kbd_backlight"; # turn on keyboard backlight.
        }

        {
          timeout = 300; # 5min
          on-timeout = "loginctl lock-session"; # lock screen when timeout has passed
        }

        {
          timeout = 330; # 5.5min
          on-timeout = "hyprctl dispatch dpms off "; # screen off when timeout has passed
          on-resume = "hyprctl dispatch dpms on"; # screen on when activity is detected after timeout has fired.
        }

        # {
        #   # timeout = 180; # 30min
        #   # on-timeout = "systemctl suspend"; # suspend pc
        # }
      ];
    };
  };

  stylix.targets.hyprpaper.enable = true;
  stylix.ls-colors.enable = true;

  gtk.iconTheme = {
    package = pkgs.papirus-icon-theme;
    name = "Papirus";
  };

  dconf.settings = {
    "org/virt-manager/virt-manager/connections" = {
      autoconnect = [ "qemu:///system" ];
      uris = [ "qemu:///system" ];
    }; # fix ui virt-manager bug
  };

}
