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

    nixpkgs.follows = "nixpkgs-stable";

    umu.url = "github:Open-Wine-Components/umu-launcher?dir=packaging/nix";

    nixpkgs-stable.url = "github:nixos/nixpkgs/nixos-25.11";

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

    nixvim = {
      url = "github:nix-community/nixvim";
      inputs.nixpkgs.follows = "nixpkgs-stable";
    };

    nix-index-database = {
      url = "github:nix-community/nix-index-database";
      inputs.nixpkgs.follows = "nixpkgs-stable";
    };

    # Dendritic tools
    flake-parts.url = "github:hercules-ci/flake-parts";
    import-tree.url = "github:vic/import-tree";

    wrapper-modules.url = "github:BirdeeHub/nix-wrapper-modules";

    noctalia = {
      url = "github:noctalia-dev/noctalia-shell";
      inputs.nixpkgs.follows = "nixpkgs-unstable";
    };

    mcp-servers-nix = {
      url = "github:natsukium/mcp-servers-nix";
    };

    gemini-cli-src = {
      url = "github:Lunitur/gemini-cli/local";
      flake = false;
    };
  };

  outputs = inputs: inputs.flake-parts.lib.mkFlake { inherit inputs; } (inputs.import-tree ./modules);
}
