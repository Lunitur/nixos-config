{
  description = "Nixos config flake";

  inputs = {
    hashcards = {
      url = "github:eudoxia0/hashcards/master";
      inputs.nixpkgs.follows = "nixpkgs-unstable";
      inputs.flake-utils.inputs.systems.follows = "systems";
    };

    # firefox-gnome-theme = {
    #   url = "github:rafaelmardojai/firefox-gnome-theme";
    #   flake = false;
    # };

    nixpkgs-unstable.url = "github:nixos/nixpkgs/nixos-unstable";
    # nixpkgs-unstable.url = "git+file:///home/carjin/nixpkgs";

    nixpkgs.follows = "nixpkgs-unstable";

    # Reaches every nixpkgs revision from this one input: mv.at "25.11",
    # mv.tip, mv.fast.tip.<attr>, (mv.flakeAt "26.05").lib.nixosSystem.
    multiverse.url = "github:fzakaria/nixpkgs-multiverse";

    nixos-hardware = {
      url = "github:NixOS/nixos-hardware/master";
      inputs.nixpkgs.follows = "nixpkgs-unstable";
    };

    home-manager = {
      url = "github:nix-community/home-manager/master";
      inputs.nixpkgs.follows = "nixpkgs-unstable";
    };

    stylix = {
      url = "github:danth/stylix/master";
      inputs.nixpkgs.follows = "nixpkgs-unstable";
      inputs.flake-parts.follows = "flake-parts";
      inputs.systems.follows = "systems";
    };

    simple-nixos-mailserver = {
      url = "gitlab:simple-nixos-mailserver/nixos-mailserver/main";
      inputs.nixpkgs.follows = "nixpkgs-unstable";
    };

    nix-index-database = {
      url = "github:nix-community/nix-index-database";
      inputs.nixpkgs.follows = "nixpkgs-unstable";
    };

    # Dendritic tools
    flake-parts.url = "github:hercules-ci/flake-parts";
    import-tree.url = "github:vic/import-tree";
    systems.url = "github:nix-systems/default";

    wrapper-modules = {
      url = "github:BirdeeHub/nix-wrapper-modules";
      inputs.nixpkgs.follows = "nixpkgs-unstable";
    };

    mcp-servers-nix = {
      url = "github:natsukium/mcp-servers-nix";
      inputs.nixpkgs.follows = "nixpkgs-unstable";
    };

  };

  outputs = inputs: inputs.flake-parts.lib.mkFlake { inherit inputs; } (inputs.import-tree ./modules);
}
