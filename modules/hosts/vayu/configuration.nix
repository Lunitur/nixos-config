{ inputs, ... }:
{
  flake.nixosConfigurations.vayu = inputs.nixpkgs-unstable.lib.nixosSystem {
    specialArgs = { inherit inputs; };
    modules = [ inputs.self.nixosModules.vayu ];
  };

  flake.nixosModules.vayu = {
    imports = [
      inputs.self.nixosModules.all
      inputs.self.nixosModules.network-base
      inputs.home-manager.nixosModules.default
      inputs.vayu.nixosModules.vayu
      inputs.vayu.nixosModules.renegade
      inputs.vayu.nixosModules.phosh
      inputs.vayu.nixosModules.stay-awake
      inputs.self.nixosModules.common-fonts
      inputs.stylix.nixosModules.stylix
      inputs.self.nixosModules.common-theme-stylix

    ];

    home-manager = {
      extraSpecialArgs = {
        inherit inputs;
        inherit (inputs) self;
      };
      backupFileExtension = "backup";
      useGlobalPkgs = true;
      users.carjin = {
        imports = [
          inputs.self.homeModules.all
          inputs.self.homeModules.common-dotfiles
          inputs.self.homeModules.git
          inputs.self.homeModules.helix
          inputs.self.homeModules.jujutsu
          inputs.self.homeModules.nushell
          inputs.self.homeModules.shell-scripts
          inputs.self.homeModules.ssh
          inputs.self.homeModules.starship
          inputs.self.homeModules.yazi
        ];
        home.username = "carjin";
        home.homeDirectory = "/home/carjin";
        home.stateVersion = "26.05";
        programs.home-manager.enable = true;
      };
    };
  };
}
