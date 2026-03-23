{
  inputs,
  ...
}:
{
  flake.nixosModules.all =
    {
      config,
      lib,
      pkgs,
      pkgs-unstable,
      ...
    }:
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
          ];
        };
      };

      nixpkgs.overlays = [
        inputs.self.overlays.inputs
        inputs.self.overlays.default
      ];

      nixpkgs.config.permittedInsecurePackages = [
        "electron-27.3.11"
        "archiver-3.5.1"
      ];

      boot.tmp.cleanOnBoot = true;

      nixpkgs.config.allowUnfree = true;
      nixpkgs.config.allowUnfreePredicate = (_: true);

      networking.networkmanager.enable = true;

      time.timeZone = "Europe/Zagreb";

      location = {
        latitude = 45.8;
        longitude = 16.0;
      };

      environment.systemPackages = with pkgs; [
        git
        nano
        file
        nix-inspect
        jq
        tree
        wget
        fastfetch
        nh
        bash
        nil # Nix language server
        fzf
        eza
        ripgrep-all
        btop
        bat
      ];

      programs.fish.enable = true;

      programs.direnv.enable = true;

      programs.gnupg.agent = {
        enable = true;
        enableSSHSupport = true;
      };

      services.openssh = {
        enable = true;
        settings = {
          PasswordAuthentication = false;
          # Disable challenge-response (often used for passwords)
          KbdInteractiveAuthentication = false;
          PubkeyAuthentication = true;
          PermitRootLogin = "prohibit-password";
        };
      };

      networking.firewall.allowedTCPPorts = [ 22 ];
      networking.firewall.allowedUDPPorts = [ 22 ];

      services.mullvad-vpn.enable = true;

      environment.variables = {
        EDITOR = "hx";
        VISUAL = "hx";
        GSETTINGS_SCHEMA_DIR = "${pkgs.gtk3}/share/gsettings-schemas/${pkgs.gtk3.name}/glib-2.0/schemas";
      };

      environment.sessionVariables = {
        FLAKE = "~/nixos";
        EDITOR = "hx";
        VISUAL = "hx";
        GSETTINGS_SCHEMA_DIR = "${pkgs.gtk3}/share/gsettings-schemas/${pkgs.gtk3.name}/glib-2.0/schemas";
      };

      nix.gc = {
        automatic = true;
        dates = "weekly";
        options = "--delete-older-than 30d";
      };

      users.defaultUserShell = pkgs.nushell;

      programs.niri.package = inputs.self.packages.${pkgs.stdenv.hostPlatform.system}.niri;

    };

  flake.homeModules.all =
    { lib, config, ... }:
    {
      programs.nushell.environmentVariables = {
        NH_FLAKE = "${config.home.homeDirectory}/nixos";
      };

    };
}
