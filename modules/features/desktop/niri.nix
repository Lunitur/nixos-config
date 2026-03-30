{ inputs, self, ... }:
{
  flake.wrapperModules.niri =
    {
      config,
      lib,
      pkgs,
      ...
    }:
    let
      theme = import ../common/theme/_green.nix;
    in
    {
      config = {
        settings = {
          environment = {
            NIXOS_OZONE_WL = "1";
            ELECTRON_OZONE_PLATFORM_HINT = "auto";
            WLR_DRM_DEVICES = "/dev/dri/card2:/dev/dri/card1";
          };

          input = {
            keyboard = {
              xkb = {
                options = "caps:escape";
                variant = "us";
                layout = "hr";
              };
            };

            touchpad = {
              natural-scroll = _: { };
              tap = _: { };
              dwt = _: { };
              accel-speed = 0.3;
            };
          };

          outputs = {
            "DP-1" = {
              scale = 1.0;
              transform = "normal";
              position = _: {
                props = {
                  x = 0;
                  y = -1080;
                };
              };
              mode = "1920x1080@143.854996";
            };
            "DP-2" = {
              scale = 1.0;
              transform = "normal";
              position = _: {
                props = {
                  x = 0;
                  y = -1080;
                };
              };
              mode = "1920x1080@143.854996";
            };
            "DSI-1" = {
              scale = 1.0;
              transform = "270";
              position = _: {
                props = {
                  x = 0;
                  y = 0;
                };
              };
              mode = "1200x1920@50.002000";
            };
            "HDMI-A-1" = {
              off = _: { };
              transform = "normal";
            };
            "eDP-1" = {
              scale = 1.0;
              transform = "normal";
              position = _: {
                props = {
                  x = 0;
                  y = 0;
                };
              };
              mode = "1920x1080@144.005005";
            };
          };

          spawn-at-startup = [
            [ "footserver" ]
            [
              "signal-desktop"
              "--start-in-tray"
            ]
            [
              "steam"
              "-silent"
            ]
            [ "noctalia-shell" ]
            [
              "wl-paste"
              "--type"
              "text"
              "--watch"
              "cliphist"
              "store"
            ]
            [
              "wl-paste"
              "--type"
              "image"
              "--watch"
              "cliphist"
              "store"
            ]
            [
              "swaybg"
              "-m"
              "fill"
              "-i"
              "${../common/theme/wallpapers/desktop6.png}"
            ]
            [
              "sh"
              "-c"
              "if [ \\\"$(hostname)\\\" = \\\"victus\\\" ]; then dispwin /etc/color-profile.icm; else dispwin -L; fi"
            ]
          ];

          prefer-no-csd = true;

          layout = {
            focus-ring = {
              width = 2;
              active-color = "#${theme.primary}";
              inactive-color = "#${theme.grey}";
            };

            border = {
              width = 4;
              active-color = "#${theme.primary}";
              inactive-color = "#${theme."grey-dark"}";
            };

            gaps = 0;
          };

          window-rules = [
            {
              geometry-corner-radius = 12.0;
              clip-to-geometry = true;
            }
            {
              matches = [ { app-id = "gemini-chat"; } ];
              open-floating = true;
              default-column-width = {
                proportion = 0.5;
              };
              default-window-height = {
                proportion = 0.8;
              };
            }
            {
              matches = [ { app-id = "chrome-gemini.google.com__-Default"; } ];
              open-floating = true;
              default-column-width = {
                proportion = 0.5;
              };
              default-window-height = {
                proportion = 0.8;
              };
            }
          ];

          workspaces = {
            "emacs-scratchpad" = { };
          };

          binds = {
            # "Mod+W".spawn = [ "pkill" "-SIGUSR1" "waybar" ];
            "Mod+Ctrl+W".spawn = [
              "pkill"
              "-SIGUSR1"
              "wlsunset"
            ];
            "Mod+G".spawn = [
              "footclient"
              "-D"
              "/home/carjin/nixos"
              "-a"
              "gemini-chat"
              "gemini"
              "-m"
              "gemini-3-flash-preview"
            ];
            "Mod+Shift+G".spawn = [ "gemini-webapp" ];
            "Mod+B".spawn = [
              "nu"
              "-c"
              "cd ~/Nextcloud; ls skripte/**/* | append (ls books/**/*) | append (ls ostalo) | append (ls cheatsheets) | where type == file | $in.name | str join (char nl) | fuzzel -d | if ($in | is-not-empty) {zathura $in}"
            ];

            "Mod+Tab".toggle-overview = _: { };
            "Ctrl+Alt+Delete".quit = _: { };

            "Mod+S".screenshot = _: { };
            "Mod+Ctrl+S".screenshot-screen = _: { };
            "Mod+Alt+S".screenshot-window = _: { };

            "Mod+J".focus-workspace-down = _: { };
            "Mod+K".focus-workspace-up = _: { };
            "Mod+Ctrl+J".move-column-to-workspace-down = _: { };
            "Mod+Ctrl+K".move-column-to-workspace-up = _: { };

            "Mod+Home".focus-column-first = _: { };
            "Mod+End".focus-column-last = _: { };
            "Mod+Ctrl+Home".move-column-to-first = _: { };
            "Mod+Ctrl+End".move-column-to-last = _: { };

            "Mod+Shift+H".focus-monitor-left = _: { };
            "Mod+Shift+J".focus-monitor-down = _: { };
            "Mod+Shift+K".focus-monitor-up = _: { };
            "Mod+Shift+L".focus-monitor-right = _: { };

            "Mod+Shift+Ctrl+H".move-column-to-monitor-left = _: { };
            "Mod+Shift+Ctrl+J".move-column-to-monitor-down = _: { };
            "Mod+Shift+Ctrl+K".move-column-to-monitor-up = _: { };
            "Mod+Shift+Ctrl+L".move-column-to-monitor-right = _: { };
            "Mod+Ctrl+H".move-column-left = _: { };
            "Mod+Ctrl+L".move-column-right = _: { };

            "Mod+BracketLeft".consume-or-expel-window-left = _: { };
            "Mod+BracketRight".consume-or-expel-window-right = _: { };

            "Mod+Comma".consume-window-into-column = _: { };
            "Mod+Period".expel-window-from-column = _: { };

            "Mod+R".switch-preset-column-width = _: { };
            "Mod+Shift+R".switch-preset-window-height = _: { };
            "Mod+Ctrl+R".reset-window-height = _: { };
            "Mod+F".maximize-column = _: { };
            "Mod+Shift+F".fullscreen-window = _: { };

            "Mod+Shift+Slash".show-hotkey-overlay = _: { };
            "Mod+Return".spawn = [ "footclient" ];
            "Mod+Q".close-window = _: { };
            "Mod+Shift+P".spawn = [
              "sh"
              "-c"
              "hyprpicker -a"
            ];
            "Mod+N".spawn = [
              "footclient"
              "yazi"
            ];
            "Mod+D".spawn = [
              "noctalia-shell"
              "ipc"
              "call"
              "launcher"
              "toggle"
            ];
            "Mod+P".toggle-window-floating = _: { };
            "Mod+E".spawn = [
              "nu"
              "~/nixos/modules/features/shell/scripts/emacs-scratchpad.nu"
            ];
            "Mod+Z".spawn = [
              "sh"
              "-c"
              "cliphist list | fuzzel -d | cliphist decode | wl-copy"
            ];
            "Mod+F1".spawn = [ "swaylock" ];
            "Mod+Shift+N".spawn = [
              "swaync-client"
              "-t"
            ];
            "Mod+O".spawn = [ "firefox" ];
            "Mod+Alt+O".spawn = [
              "firefox"
              "https://search.nixos.org/options"
            ];
            "Mod+Alt+P".spawn = [
              "firefox"
              "https://search.nixos.org/packages"
            ];
            "Mod+Alt+G".spawn = [
              "firefox"
              "https://gemini.google.com"
            ];

            "Mod+Shift+W".spawn = [
              "looking-glass-client"
              "-f"
              "/dev/kvmfr0"
              "-m"
              "KEY_INSERT"
              "-F"
              "-T"
            ];
            "Mod+Shift+V".spawn = [ "blueman-manager" ];
            "Mod+V".spawn = [ "pavucontrol" ];
            "Mod+H".focus-column-left = _: { };
            "Mod+L".focus-column-right = _: { };

            "Mod+1".focus-workspace = 1;
            "Mod+2".focus-workspace = 2;
            "Mod+3".focus-workspace = 3;
            "Mod+4".focus-workspace = 4;
            "Mod+5".focus-workspace = 5;
            "Mod+6".focus-workspace = 6;
            "Mod+7".focus-workspace = 7;
            "Mod+8".focus-workspace = 8;
            "Mod+9".focus-workspace = 9;
            "Mod+0".focus-workspace = 10;

            "Mod+Shift+1".move-window-to-workspace = 1;
            "Mod+Shift+2".move-window-to-workspace = 2;
            "Mod+Shift+3".move-window-to-workspace = 3;
            "Mod+Shift+4".move-window-to-workspace = 4;
            "Mod+Shift+5".move-window-to-workspace = 5;
            "Mod+Shift+6".move-window-to-workspace = 6;
            "Mod+Shift+7".move-window-to-workspace = 7;
            "Mod+Shift+8".move-window-to-workspace = 8;
            "Mod+Shift+9".move-window-to-workspace = 9;
            "Mod+Shift+0".move-window-to-workspace = 10;

            "XF86AudioRaiseVolume".spawn = [
              "wpctl"
              "set-volume"
              "-l"
              "1"
              "@DEFAULT_AUDIO_SINK@"
              "5%+"
            ];
            "XF86AudioLowerVolume".spawn = [
              "wpctl"
              "set-volume"
              "@DEFAULT_AUDIO_SINK@"
              "5%-"
            ];
            "XF86AudioMute".spawn = [
              "wpctl"
              "set-mute"
              "@DEFAULT_AUDIO_SINK@"
              "toggle"
            ];
            "XF86AudioMicMute".spawn = [
              "wpctl"
              "set-mute"
              "@DEFAULT_AUDIO_SOURCE@"
              "toggle"
            ];
            "XF86MonBrightnessUp".spawn = [
              "brightnessctl"
              "s"
              "10%+"
            ];
            "XF86MonBrightnessDown".spawn = [
              "brightnessctl"
              "s"
              "10%-"
            ];
            "XF86AudioNext".spawn = [
              "playerctl"
              "next"
            ];
            "XF86AudioPause".spawn = [
              "playerctl"
              "play-pause"
            ];
            "XF86AudioPlay".spawn = [
              "playerctl"
              "play-pause"
            ];
            "XF86AudioPrev".spawn = [
              "playerctl"
              "previous"
            ];
          };
        };
      };
    };

  perSystem =
    { pkgs, ... }:
    let
      wrappedNiri = inputs.wrapper-modules.wrappers.niri.wrap {
        inherit pkgs;
        imports = [ self.wrapperModules.niri ];
      };
    in
    {
      packages.niri = pkgs.symlinkJoin {
        name = "niri-wrapped";
        paths = [ wrappedNiri ];
        passthru = {
          cargoBuildNoDefaultFeatures = pkgs.niri.cargoBuildNoDefaultFeatures or false;
          cargoBuildFeatures = pkgs.niri.cargoBuildFeatures or [ ];
          providedSessions = pkgs.niri.providedSessions or [ "niri" ];
        };
        meta.mainProgram = "niri";
      };
    };

  flake.homeModules.desktop-niri =
    {
      pkgs,
      osConfig,
      lib,
      inputs,
      pkgs-unstable,
      ...
    }:
    {
      services.swayidle = {
        enable = true;
        events = [
          {
            event = "before-sleep";
            command = "${pkgs.swaylock-effects}/bin/swaylock -f";
          }
          {
            event = "lock";
            command = "${pkgs.swaylock-effects}/bin/swaylock -f";
          }
        ];
        timeouts = [
          {
            timeout = 600;
            command = "${pkgs.brightnessctl}/bin/brightnessctl -s set 10";
            resumeCommand = "${pkgs.brightnessctl}/bin/brightnessctl -r";
          }
          {
            timeout = 150;
            command = "${pkgs.brightnessctl}/bin/brightnessctl -sd rgb:kbd_backlight set 0";
            resumeCommand = "${pkgs.brightnessctl}/bin/brightnessctl -rd rgb:kbd_backlight";
          }
          {
            timeout = 900;
            command = "${pkgs.systemd}/bin/loginctl lock-session";
          }
          {
            timeout = 630;
            command = "${lib.getExe pkgs.niri} msg action power-off-monitors";
          }
        ];
      };

      programs.swaylock = {
        enable = true;
        package = pkgs.swaylock-effects;
        settings = {
          screenshots = true;
          clock = true;
          indicator = true;
          indicator-radius = 400;
          indicator-thickness = 20;
          effect-blur = "8x3";
          fade-in = 0.5;
          datestr = "%B %d, %Y";
          timestr = "%I:%M %p";
          font-size = 100;
        };
      };

      services.wlsunset = {
        enable = false;
        sunrise = "06:00";
        sunset = "19:00";
        temperature = {
          day = 6500;
          night = 3500;
        };
      };

      home.packages = with pkgs; [
        inputs.self.packages.${pkgs.stdenv.hostPlatform.system}.niri
        inputs.self.packages.${pkgs.stdenv.hostPlatform.system}.noctalia
        loupe
        swaybg
        networkmanagerapplet
        wlr-randr
        pavucontrol
        brightnessctl
        cliphist
        wl-clipboard
        playerctl
        xwayland-satellite
        nautilus # required for file picker to work
        mission-center
        imv
        sunsetr
      ];
    };
}
