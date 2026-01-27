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
    
    nixpkgs.follows = "nixpkgs-unstable";

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

    flake-parts = {
      url = "github:hercules-ci/flake-parts";
      inputs.nixpkgs-lib.follows = "nixpkgs-stable";
    };

    import-tree.url = "github:vic/import-tree";
  };

  outputs =
    inputs@{ flake-parts, ... }:
    flake-parts.lib.mkFlake { inherit inputs; }
      (inputs.import-tree ./tree);
}
