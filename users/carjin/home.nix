{ config, pkgs, pkgs-stable, modules, ... }:

{

  imports = [
    modules.nushell
    # modules.nixvim
    modules.stylix-hm
    ../../dotfiles
  ];

  home.username = "carjin";
  home.homeDirectory = "/home/carjin";

  home.stateVersion = "23.11";

  home.packages = (with pkgs; [
    nmap
    # haskell-language-server
    ani-cli
    dconf
    alacritty
    anki-bin
    mpv
    deluge-gtk
    libreoffice
    osu-lazer-bin
    protonup-ng
    xfce.xfce4-taskmanager

  ]) ++ (with pkgs-stable; [
    (rstudioWrapper.override { packages = with rPackages; [ ggplot2 dplyr xts tidyverse ]; })
  ]);

  home.file = { };

  home.sessionVariables = {
    # EDITOR = "emacs";
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

  programs.vscode = {
    enable = true;
    package = pkgs.vscode.fhsWithPackages (ps: with ps; [
      rustup
      zlib
      openssl.dev
      pkg-config
      haskell.compiler.ghc966
      (haskell-language-server.override { supportedGhcVersions = [ "96" ]; })
    ]
    );
    extensions = with pkgs.vscode-extensions; [
      #      dracula-theme.theme-dracula
      #      vscodevim.vim
      #      yzhang.markdown-all-in-one
      thenuprojectcontributors.vscode-nushell-lang
      julialang.language-julia
      haskell.haskell
      #      justusadan.language-haskell
      betterthantomorrow.calva
      #      unison-lang.unison
      jnoortheen.nix-ide
      arrterian.nix-env-selector
      mkhl.direnv
    ];
  };

  programs.git = {
    enable = true;
    userEmail = "karlo.puselj@gmail.com";
    userName = "Lunitur";
  };


  dconf.enable = true;
  programs.alacritty.enable = true;

  nixpkgs.config.allowUnfree = true;

  programs.helix = {
    enable = true;
    languages.language = [{
      name = "nix";
      auto-format = true;
      formatter.command = "${pkgs.nixfmt}/bin/nixfmt";
    }];
    settings = {
      editor.lsp = {
        display-inlay-hints = true;
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
