{ ... }:
{
  flake.nixosModules.moonshine =
    {
      config,
      lib,
      pkgs,
      ...
    }:
    let
      cfg = config.services.moonshine;

      tomlFormat = pkgs.formats.toml { };

      # The declarative config, materialised in the store instead of a dotfile.
      configFile = tomlFormat.generate "moonshine-config.toml" cfg.settings;

      # Run script that launches moonshine with the store config baked in. Sets
      # XDG_RUNTIME_DIR / DBUS (required for Wayland sockets and `systemd-run
      # --user`) since a system service does not get them. Usable both as the
      # service ExecStart and by hand from a shell.
      runScript = pkgs.writeShellScriptBin "moonshine-server" ''
        export XDG_RUNTIME_DIR="''${XDG_RUNTIME_DIR:-/run/user/$(id -u)}"
        export DBUS_SESSION_BUS_ADDRESS="''${DBUS_SESSION_BUS_ADDRESS:-unix:path=$XDG_RUNTIME_DIR/bus}"
        exec ${lib.getExe cfg.package} ${configFile} "$@"
      '';
    in
    {
      options.services.moonshine = {
        enable = lib.mkEnableOption "Moonshine headless game streaming server";

        package = lib.mkPackageOption pkgs "moonshine" { };

        extraPackages = lib.mkOption {
          type = lib.types.listOf lib.types.package;
          default = [ ];
          example = lib.literalExpression "[ pkgs.steam ]";
          description = ''
            Packages added to the service PATH for application commands launched
            by Moonshine.
          '';
        };

        environment = lib.mkOption {
          type = lib.types.attrsOf lib.types.str;
          default = { };
          example = {
            MESA_VK_DEVICE_SELECT = "10de:25a2!";
          };
          description = ''
            Environment variables set for Moonshine and inherited by launched
            applications.
          '';
        };

        users = lib.mkOption {
          type = lib.types.listOf lib.types.str;
          default = [ ];
          example = [ "alice" ];
          description = ''
            Users to run a Moonshine instance for. Each listed user gets a
            `moonshine-<user>` system service launched via the `moonshine-server`
            run script (which loads the generated config), and has lingering
            enabled so the server runs without an active login session.

            The users must be defined elsewhere; the service adds `input` as a
            supplementary group for virtual-input access.
          '';
        };

        settings = lib.mkOption {
          type = tomlFormat.type;
          default = { };
          example = lib.literalExpression ''
            {
              name = "my-desktop";
              address = "0.0.0.0";

              application = [
                {
                  title = "Steam";
                  command = [ "steam" "steam://open/bigpicture" ];
                }
                {
                  title = "Desktop";
                  command = [ ];
                }
              ];

              application_scanner = [
                {
                  type = "steam";
                  library = "$HOME/.local/share/Steam";
                  command = [ "steam" "-bigpicture" "steam://rungameid/{game_id}" ];
                }
              ];
            }
          '';
          description = ''
            Moonshine configuration. Rendered to a TOML file in the Nix store and
            loaded by the `moonshine-server` run script — no dotfile is written to
            the user's home. All fields are optional and fall back to Moonshine's
            defaults; see upstream `moonshine-core/src/config.rs` for the full
            schema. Applications use the `application` array-of-tables key
            (rendered as `[[application]]`).
          '';
        };

        openFirewall = lib.mkOption {
          type = lib.types.bool;
          default = true;
          description = "Open the Moonlight/GameStream ports in the firewall.";
        };
      };

      config = lib.mkIf cfg.enable {
        environment.systemPackages = [
          cfg.package
          runScript
        ];

        # udev rules granting access to /dev/uinput and /dev/uhid, plus the
        # kernel modules that back inputtino's virtual input devices.
        services.udev.packages = [ cfg.package ];
        boot.kernelModules = [
          "uinput"
          "uhid"
        ];

        # Expose the moonshine-wsi implicit Vulkan layer to every Vulkan client
        # via /run/opengl-driver, so it is present in the games moonshine
        # launches. moonshine sets ENABLE_MOONSHINE_WSI=1 per game to activate it.
        hardware.graphics.enable = lib.mkDefault true;
        hardware.graphics.extraPackages = [ cfg.package ];

        networking.firewall = lib.mkIf cfg.openFirewall {
          allowedTCPPorts = [
            47984
            47989
            48010
          ];
          allowedUDPPorts = [
            47998
            47999
            48000
            48002
            48010
          ];
        };

        users.users = lib.genAttrs cfg.users (_: {
          linger = true;
        });

        systemd.services = lib.mkMerge (
          map (user: {
            "moonshine-${user}" = {
              description = "Moonshine game streaming server for ${user}";
              wantedBy = [ "multi-user.target" ];
              after = [ "network.target" ];
              path = cfg.extraPackages;
              serviceConfig = {
                User = user;
                SupplementaryGroups = [ "input" ];
                ExecStart = lib.getExe runScript;
                Restart = "always";
                RestartSec = 5;
                Environment = [
                  "MOONSHINE_LOG=moonshine=info"
                ]
                ++ lib.mapAttrsToList (name: value: "${name}=${value}") cfg.environment;
                # Access to virtual input and the GPU (DRM / NVIDIA nodes).
                DeviceAllow = [
                  "/dev/uinput rw"
                  "/dev/uhid rw"
                  "char-drm rw"
                  "char-nvidia rw"
                  "char-nvidia-uvm rw"
                ];
              };
            };
          }) cfg.users
        );
      };
    };
}
