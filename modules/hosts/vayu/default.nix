{ inputs, ... }:
{
  flake.nixosModules.vayu =
    {
      config,
      lib,
      options,
      pkgs,
      ...
    }:
    {
      imports = [
        inputs.self.nixosModules.user-carjin
      ];

      # Keep cached GNOME/Phosh packages instead of rebuilding them for theme changes.
      stylix.overlays.enable = false;

      users.users.root.openssh.authorizedKeys.keys =
        config.users.users.carjin.openssh.authorizedKeys.keys;

      networking.hostName = "vayu";
      networking.firewall = {
        trustedInterfaces = [ "wt0" ];
        checkReversePath = "loose";
      };

      services = lib.setAttrByPath (
        if options.services ? desktopManager.phosh then
          [
            "desktopManager"
            "phosh"
          ]
        else
          [
            "xserver"
            "desktopManager"
            "phosh"
          ]
      ) {
        user = "carjin";
        group = "users";
      };

      environment.systemPackages = with pkgs; [
        btrfs-progs
        firefox
        gnome-console
        nautilus
        epiphany
        gnome-text-editor
        loupe
        papers
        gnome-calculator
        gnome-clocks
        gnome-weather
        gnome-calendar
        fractal
        warp
        gnome-secrets
        authenticator
        amberol
        gnome-podcasts
        geary
        gnome-maps
        foliate
        planify
        shortwave
        newsflash
        dialect
        clapper
        tuba
        valent
        (pipeline.overrideAttrs (old: {
          # Backport the feed-loading fix until Nixpkgs ships Pipeline 4.1.1.
          patches =
            (old.patches or [ ])
            ++ lib.optional (lib.versionOlder old.version "4.1.1") (fetchurl {
              url = "https://gitlab.com/schmiddi-on-mobile/pipeline/-/commit/3d72f421194bedaa66bc78bd4a45cc91ea07a4dd.patch";
              hash = "sha256-Ua0aHciuHEXLA3tIBY6ToFsA9ea1GCDq4KGueV02Suk=";
            });
        }))
        monophony
      ];

      system.stateVersion = "26.05";
    };
}
