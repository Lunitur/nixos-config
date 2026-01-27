{ config, ... }: {
  flake.modules.nixos.hosts.default = { config, lib, pkgs, pkgs-unstable, ... }:
  {
    imports = [ ];

    nix = {
      settings = {
        experimental-features = [
          "nix-command"
          "flakes"
        ];
        substituters = [
          "https://nix-community.cachix.org"
          "https://cache.nixos.org"
        ];
        extra-substituters = [
          "https://victus.cachix.org"
        ];
        trusted-public-keys = [
          "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
        ];
        extra-trusted-public-keys = [
          "victus.cachix.org-1:VQvwDrGr4O3e1G64Xl97fl2QdHRxr3LieTYldF84jIY="
          "victus.akita-bleak.ts.net:kb/jFWfxfUVJfWlLeu+qEYO3zGkNHdfCvb61qSHRo3A="
        ];
        trusted-users = [
          "root"
          "carjin"
          # "lsimek"
        ];
      };
    };

    # Use the overlays defined in the flake
    nixpkgs.overlays = [ 
      config.flake.overlays.brother 
      config.flake.overlays.my-packages
    ];

    nixpkgs.config.permittedInsecurePackages = [
      "electron-27.3.11"
      "archiver-3.5.1"
    ];

    # niri-flake.cache.enable = false; # niri-flake not available here unless in specialArgs? 
    # Original used `niri-flake.cache.enable = false;`?
    # Check original hosts/default.nix. 
    # It imported `inputs`? No.
    # It accessed `niri-flake` variable?
    # The original file imports had `niri` in inputs. 
    # Wait, `hosts/default.nix` had `niri-flake.cache.enable = false;`.
    # Where does `niri-flake` come from? 
    # Ah, `pkgs-unstable` was passed. `niri` was passed in `specialArgs`?
    # Check `flake.nix`.
    # `specialArgs = { inherit pkgs-unstable ... inputs; };`
    # It passed `inputs` but not `niri-flake`.
    # But `niri` input IS `niri-flake`.
    # So `inputs.niri` is available.
    # The original code `niri-flake.cache.enable` implies `niri-flake` was in scope?
    # `hosts/default.nix` args: `{ config, lib, pkgs, pkgs-unstable, ... }`.
    # It does NOT list `niri-flake`.
    # So it must be from `...` or implicit?
    # Maybe `niri` module defines the option?
    # Yes, `niri.nixosModules.niri` adds options.
    # But `niri-flake.cache.enable` looks like an option name.
    # So I can just set it.
    
    # But wait, `hosts/default.nix` has `niri-flake.cache.enable = false;`.
    # If this is an option defined by a module, I can set it.
    
    boot.tmp.cleanOnBoot = true;

    nixpkgs.config.allowUnfree = true;

    networking.networkmanager.enable = true;

    time.timeZone = "Europe/Zagreb";

    location = {
      latitude = 45.8;
      longitude = 16.0;
    };

    environment.systemPackages =
      (with pkgs; [
        nix-inspect
        git
        tree
        wget
        nushell
        gvfs
        pueue
        fastfetch
        unar
        nixfmt-rfc-style
        nh
        bash
        xarchiver
        nil # Nix language server
        cabal-install
        fzf
        eza
        carapace
        ripgrep-all
        mc
        btop
        bat
      ])
      ++ [ pkgs.ammonite.ammonite_3_5 ]; # Use overlay version

    programs.fish.enable = true;

    programs.direnv.enable = true;

    programs.gnupg.agent = {
      enable = true;
      enableSSHSupport = true;
    };

    services.openssh.enable = true;
    services.openssh.settings.PasswordAuthentication = false;

    networking.firewall.allowedTCPPorts = [ 22 ];
    networking.firewall.allowedUDPPorts = [ 22 ];

    services.mullvad-vpn.enable = true;

    environment.variables = {
      EDITOR = "hx";
      VISUAL = "hx";
    };

    environment.sessionVariables = {
      EDITOR = "hx";
      VISUAL = "hx";
    };

    nix.gc = {
      automatic = true;
      dates = "weekly";
      options = "--delete-older-than 30d";
    };

    users.defaultUserShell = pkgs.nushell;

  };
}
