{
  description = "Nixos config flake";

  inputs = {
    arhivar = {
      url = "gitlab:Lunitur/arhivar/main";
    };

    hashcards = {
      url = "github:eudoxia0/hashcards/master";
      inputs.nixpkgs.follows = "nixpkgs-unstable";
    };

    firefox-gnome-theme = {
      url = "github:rafaelmardojai/firefox-gnome-theme";
      flake = false;
    };

    nixpkgs-unstable.url = "github:nixos/nixpkgs/master";
    # nixpkgs-unstable.url = "github:Lunitur/nixpkgs/master";

    umu.url = "github:Open-Wine-Components/umu-launcher?dir=packaging/nix";

    nixpkgs-stable.url = "github:nixos/nixpkgs/nixos-25.11";
    # nixpkgs-stable.url = "path:/home/carjin/nixpkgs";

    nixos-hardware.url = "github:NixOS/nixos-hardware/master";

    home-manager-stable = {
      url = "github:nix-community/home-manager/release-25.11";
      inputs.nixpkgs.follows = "nixpkgs-stable";
    };

    stylix = {
      url = "github:danth/stylix/release-25.11";
      inputs.nixpkgs.follows = "nixpkgs-stable";
    };

    simple-nixos-mailserver.url = "gitlab:simple-nixos-mailserver/nixos-mailserver/nixos-25.11";

    niri = {
      url = "github:sodiboo/niri-flake";
      inputs.nixpkgs.follows = "nixpkgs-stable";
    };

    nixvim = {
      url = "github:nix-community/nixvim";
      inputs.nixpkgs.follows = "nixpkgs-stable";
    };

    colord = {
      url = "path:/home/carjin/colord";
      flake = false;
    };

    nix-index-database = {
      url = "github:nix-community/nix-index-database";
      inputs.nixpkgs.follows = "nixpkgs-stable";
    };
  };

  outputs =
    {
      self,
      nixpkgs-unstable,
      nixpkgs-stable,
      nixos-hardware,
      home-manager-stable,
      simple-nixos-mailserver,
      stylix,
      niri,
      nixvim,
      nix-index-database,
      ...
    }@inputs:
    let
      pkgs-unstable = import nixpkgs-unstable {
        system = "x86_64-linux";
        config.allowUnfree = true;
        overlays = [ ];
      };
      pkgs-unstable-arm = import nixpkgs-unstable {
        system = "aarch64-linux";
        config.allowUnfree = true;
        overlays = [ ];
      };
      specialArgs = {
        inherit
          pkgs-unstable
          pkgs-unstable-arm
          inputs
          niri
          nixvim
          ;
      };
    in
    {
      nixosConfigurations.victus = nixpkgs-stable.lib.nixosSystem {
        inherit specialArgs;
        system = "x86_64-linux";
        modules = [
          ./hosts/victus
          ./hosts # defaults
          ./modules/features/all.nix
          nixos-hardware.nixosModules.common-cpu-amd
          nixos-hardware.nixosModules.common-cpu-amd-pstate
          nixos-hardware.nixosModules.common-pc-laptop
          nixos-hardware.nixosModules.common-pc-laptop-ssd
          nixos-hardware.nixosModules.common-hidpi
          nix-index-database.nixosModules.default
          home-manager-stable.nixosModules.default
          stylix.nixosModules.stylix
          niri.nixosModules.niri
          {
            features = {
              desktop = {
                niri.enable = true;
                waybar.enable = true;
                foot.enable = true;
                kitty.enable = true;
                fuzzel.enable = true;
                swaync.enable = true;
              };
              editors = {
                helix.enable = true;
                emacs.enable = true;
              };
              shell = {
                zsh.enable = true;
                nushell.enable = true;
                starship.enable = true;
                git.enable = true;
                ssh.enable = true;
                jujutsu.enable = true;
                yazi.enable = true;
              };
              apps = {
                firefox.enable = true;
                mpv.enable = true;
                zathura.enable = true;
                typst.enable = true;
                gemini-cli.enable = true;
              };
              services = {
                pueue.enable = true;
                udiskie.enable = true;
              };
              network = {
                base.enable = true;
                tailscale.enable = true;
                syncthing.enable = true;
                spotify.enable = true;
                avahi.enable = true;
              };
              common = {
                theme.stylix.enable = true;
                dotfiles.enable = true;
                fonts.enable = true;
                packages.enable = true;
                xdg-mime.enable = true;
              };
            };

            home-manager = {
              # also pass inputs to home-manager modules
              extraSpecialArgs = {
                inherit pkgs-unstable inputs;
              };
              users = {
                carjin = {
                  home.username = "carjin";
                  home.homeDirectory = "/home/carjin";
                  home.stateVersion = "23.11";
                  programs.home-manager.enable = true;
                };
              };

              backupFileExtension = "backup";
              useGlobalPkgs = true;
            };
          }
        ];
      };
      nixosConfigurations.minibook = nixpkgs-stable.lib.nixosSystem {
        inherit specialArgs;
        system = "x86_64-linux";
        modules = [
          ./hosts/minibook
          ./hosts # defaults
          ./modules/features/all.nix
          nixos-hardware.nixosModules.chuwi-minibook-x
          nixos-hardware.nixosModules.common-cpu-intel
          nixos-hardware.nixosModules.common-pc-laptop
          nixos-hardware.nixosModules.common-pc-laptop-ssd
          nixos-hardware.nixosModules.common-hidpi
          home-manager-stable.nixosModules.default
          stylix.nixosModules.stylix
          niri.nixosModules.niri
          nix-index-database.nixosModules.default
          {
            features = {
              desktop = {
                niri.enable = true;
                waybar.enable = true;
                foot.enable = true;
                fuzzel.enable = true;
                swaync.enable = true;
              };
              editors.helix.enable = true;
              shell = {
                zsh.enable = true;
                nushell.enable = true;
                starship.enable = true;
                git.enable = true;
                yazi.enable = true;
              };
              apps = {
                firefox.enable = true;
                mpv.enable = true;
              };
              services.udiskie.enable = true;
              network.base.enable = true;
              common = {
                theme.stylix.enable = true;
                dotfiles.enable = true;
                fonts.enable = true;
                packages.enable = true;
              };
            };

            home-manager = {
              extraSpecialArgs = {
                inherit pkgs-unstable inputs;
              };
              users = {
                carjin = {
                  home.username = "carjin";
                  home.homeDirectory = "/home/carjin";
                  home.stateVersion = "23.11";
                  programs.home-manager.enable = true;
                };
              };

              backupFileExtension = "backup";
              useGlobalPkgs = true;
            };

            nix.settings = {
              substituters = [ "https://cosmic.cachix.org/" ];
              trusted-public-keys = [ "cosmic.cachix.org-1:Dya9IyXD4xdBehWjrkPv6rtxpmMdRel02smYzA85dPE=" ];
            };
          }
        ];
      };
      nixosConfigurations.corebook = nixpkgs-stable.lib.nixosSystem {
        inherit specialArgs;
        system = "x86_64-linux";
        modules = [
          ./hosts/corebook
          ./hosts # defaults
          ./modules/features/all.nix
          nixos-hardware.nixosModules.common-cpu-intel
          nixos-hardware.nixosModules.common-pc-laptop
          nixos-hardware.nixosModules.common-pc-laptop-ssd
          nixos-hardware.nixosModules.common-hidpi
          home-manager-stable.nixosModules.default
          stylix.nixosModules.stylix
          niri.nixosModules.niri
          nix-index-database.nixosModules.default
          {
            features = {
              desktop = {
                niri.enable = true;
                waybar.enable = true;
                foot.enable = true;
                fuzzel.enable = true;
              };
              editors.helix.enable = true;
              shell = {
                zsh.enable = true;
                nushell.enable = true;
                starship.enable = true;
                git.enable = true;
              };
              apps.firefox.enable = true;
              network.base.enable = true;
              common = {
                theme.stylix.enable = true;
                dotfiles.enable = true;
                fonts.enable = true;
                packages.enable = true;
              };
            };

            home-manager = {
              extraSpecialArgs = {
                inherit pkgs-unstable inputs;
              };
              users = {
                carjin = {
                  home.username = "carjin";
                  home.homeDirectory = "/home/carjin";
                  home.stateVersion = "23.11";
                  programs.home-manager.enable = true;
                };
              };

              backupFileExtension = "backup";
              useGlobalPkgs = true;
            };

            nix.settings = {
              substituters = [ "https://cosmic.cachix.org/" ];
              trusted-public-keys = [ "cosmic.cachix.org-1:Dya9IyXD4xdBehWjrkPv6rtxpmMdRel02smYzA85dPE=" ];
            };

          }
          # nixos-cosmic.nixosModules.default
        ];
      };
      nixosConfigurations.nano = nixpkgs-stable.lib.nixosSystem {
        inherit specialArgs;
        system = "aarch64-linux";
        modules = [
          ./hosts/nano
          ./users/carjin
          ./modules/features/all.nix
          simple-nixos-mailserver.nixosModule
          home-manager-stable.nixosModules.default
          stylix.nixosModules.stylix
          {
            features = {
              hardware.audio.enable = false;
              editors.helix.enable = true;
              shell = {
                zsh.enable = true;
                nushell.enable = true;
                starship.enable = true;
                git.enable = true;
                ssh.enable = true;
                jujutsu.enable = true;
                yazi.enable = true;
              };
              apps.gemini-cli.enable = true;
              services.pueue.enable = true;
              network = {
                headscale.enable = true;
                tailscale.enable = true;
                base.enable = true;
              };
              common = {
                theme.stylix.enable = true;
                dotfiles.enable = true;
                xdg-mime.enable = true;
              };
            };

            home-manager = {
              extraSpecialArgs = {
                inherit pkgs-unstable inputs;
              };
              users = {
                carjin = {
                  home.username = "carjin";
                  home.homeDirectory = "/home/carjin";
                  home.stateVersion = "23.11";
                  programs.home-manager.enable = true;
                };
              };

              backupFileExtension = "backup";
              useGlobalPkgs = true;
            };
          }
        ];
      };
    };
}
