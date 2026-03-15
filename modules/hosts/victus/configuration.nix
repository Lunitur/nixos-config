{
  inputs,
  ...
}:
{
  flake.modules.nixos.victus = {
    imports = [
      inputs.self.modules.nixos.victus-base
      inputs.self.modules.nixos.hosts-default
      inputs.self.modules.nixos.allFeatures
      inputs.nixos-hardware.nixosModules.common-cpu-amd
      inputs.nixos-hardware.nixosModules.common-cpu-amd-pstate
      inputs.nixos-hardware.nixosModules.common-pc-laptop
      inputs.nixos-hardware.nixosModules.common-pc-laptop-ssd
      inputs.nixos-hardware.nixosModules.common-hidpi
      inputs.nix-index-database.nixosModules.default
      inputs.home-manager-stable.nixosModules.default
      inputs.stylix.nixosModules.stylix
      inputs.niri.nixosModules.niri
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
            inherit inputs;
            inherit (inputs) self;
            pkgs-unstable = import inputs.nixpkgs-unstable {
                system = "x86_64-linux";
                config.allowUnfree = true;
            };
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
}
