{
  config,
  lib,
  pkgs,
  pkgs-unstable,
  ...
}:
let
  user-pkgs = import ../packages { inherit pkgs; };
in
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

  nixpkgs.overlays = [ (import ../overlays/brother.nix) ];

  nixpkgs.config.permittedInsecurePackages = [
    "electron-27.3.11"
    "archiver-3.5.1"
  ];

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
      git
      tree
      wget
      nano
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
      sbt
      mill
      metals
      julia
      fzf
      zoxide
      eza
      carapace
      ripgrep-all
      mc
      btop
      bat
      ihp-new
    ])
    ++ (with user-pkgs; [ ammonite.ammonite_3_5 ]);

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

  nix.gc = {
    automatic = true;
    dates = "weekly";
    options = "--delete-older-than 30d";
  };

  users.defaultUserShell = pkgs.nushell;

}
