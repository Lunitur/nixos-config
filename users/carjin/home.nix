{
  pkgs-unstable,
  modules,
  pkgs,
  ...
}:

{

  imports = [
    modules.nushell
    # modules.nixvim
    modules.stylix-hm
    ./dotfiles.nix
  ];

  home.username = "carjin";
  home.homeDirectory = "/home/carjin";

  home.stateVersion = "23.11";

  programs.fish = {
    enable = true;
    shellAliases = {

    };

  };

  stylix.targets.fish.enable = true;

  programs.direnv.enableFishIntegration = true;
  programs.zoxide.enableFishIntegration = true;
  programs.nix-index.enableFishIntegration = true;
  programs.fzf.enableFishIntegration = true;
  programs.carapace.enableFishIntegration = true;
  programs.oh-my-posh.enableFishIntegration = true;
  programs.dircolors.enableFishIntegration = true;
  programs.autojump.enableFishIntegration = true;

  home.packages =
    (with pkgs-unstable; [
      tldr
      nmap
      ani-cli
      protonup-ng
    ])
    ++ (with pkgs; [
      calibre
      logseq
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

      (rstudioWrapper.override {
        packages = with rPackages; [
          ggplot2
          dplyr
          xts
          tidyverse
        ];
      })
    ]);

  home.file = { };

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

  # programs.vscode = {
  #   enable = true;
  #   extensions = with pkgs-stable.vscode-extensions; [
  #     #      dracula-theme.theme-dracula
  #     #      vscodevim.vim
  #     #      yzhang.markdown-all-in-one
  #     thenuprojectcontributors.vscode-nushell-lang
  #     julialang.language-julia
  #     haskell.haskell
  #     #      justusadan.language-haskell
  #     betterthantomorrow.calva
  #     #      unison-lang.unison
  #     jnoortheen.nix-ide
  #     arrterian.nix-env-selector
  #     mkhl.direnv
  #   ];
  # };

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

  nixpkgs.config.allowUnfree = true;

  programs.helix = {
    enable = true;
    languages = {
      language-server.metals.config.metals = {
        autoImportBuild = "all";
      };
      language = [
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
      theme = "tokyonight";
      editor.lsp = {
        display-inlay-hints = true;
      };
    };
    themes = {
      autumn_night_transparent = {
        "inherits" = "autumn_night";
        "ui.background" = { };
      };
    };
  };

  stylix.targets.helix.enable = false;
  stylix.targets.kde.enable = false;

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
