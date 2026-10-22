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
        interfaces.wld0 = {
          allowedUDPPorts = [ 53 ];
          allowedTCPPorts = [ 53 ];
        };
      };

      services =
        lib.setAttrByPath
          (
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
          )
          {
            user = "carjin";
            group = "users";
          };

      environment.systemPackages = with pkgs; [
        btrfs-progs
        firefox
        brave
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
        (amberol.override {
          reuse = reuse.overridePythonAttrs {
            # sphinxHook reads a string; a structured array drops the man builder.
            sphinxBuilders = "html man";
          };
        })
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

        tlrc
        nmap
        (pkgs.ani-cli.overrideAttrs (old: {
          src = pkgs.fetchFromGitHub {
            owner = "pystardust";
            repo = "ani-cli";
            tag = "v4.14";
            hash = "sha256-OyCKDN89sBz59+3JncMDyNOq8UMqqjara+A0Owo3oko=";
          };
          nativeBuildInputs = (old.nativeBuildInputs or [ ]) ++ [ pkgs.makeWrapper ];
          postInstall = (old.postInstall or "") + ''
            wrapProgram $out/bin/ani-cli --prefix PATH : ${pkgs.openssl}/bin
          '';
        }))
        nodejs
        prismlauncher
        ytfzf
        pandoc
        moonlight-qt
        ytmdl
        xfce4-taskmanager
        signal-desktop
        element-desktop
        mupdf
        nextcloud-client
        # lutris
        # deluge-gtk
        transmission_4-gtk
        dconf
        gedit
        (pkgs.symlinkJoin {
          name = "libreoffice";
          paths = [ pkgs.libreoffice ];
          nativeBuildInputs = [ pkgs.makeWrapper ];
          postBuild = ''
            for bin in $out/bin/*; do
              wrapProgram "$bin" \
                --set SAL_USE_VCLPLUGIN gtk3 \
                --set GDK_BACKEND wayland \
                --set GTK_THEME Adwaita:light
            done
          '';
        })
        thunderbird
        halloy
        yt-dlp
        bemoji
        jq
      ];

      boot.loader.systemd-boot.configurationLimit = 10;

      system.stateVersion = "26.05";
    };
}
