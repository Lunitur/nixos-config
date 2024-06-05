{ inputs, modules, pkgs-unstable, pkgs-stable, nixvim, stylix, ... }:
{
  imports = [
    ./carjin/user.nix
    ./lsimek/user.nix
  ];

  home-manager = {
    # also pass inputs to home-manager modules
    extraSpecialArgs = { inherit modules pkgs-unstable pkgs-stable nixvim stylix; };
    users = {
      carjin = import ./carjin/home.nix;
      lsimek = import ./lsimek/home.nix;
    };

    backupFileExtension = "backup";
  };
}
