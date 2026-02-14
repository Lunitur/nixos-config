{
  pkgs,
  osConfig,
  lib,
  inputs,
  pkgs-unstable,
  ...
}:
let
  theme = import ../theme/green.nix;
in
{
  imports = [
    ./idle.nix
    ./lock.nix
    ./sunset.nix
  ];

  programs.niri.config = ''
    environment {
        NIXOS_OZONE_WL "1"
        ELECTRON_OZONE_PLATFORM_HINT "auto"
    }

    input {
        keyboard {
            xkb {
                options "caps:escape"
                variant "us"
                layout "hr"
            }
        }

        touchpad {
            natural-scroll
            tap
            dwt
            accel-speed 0.3
        }
    }

    output "DP-1" {
        scale 1.000000
        transform "normal"
        position x=0 y=-1080
        mode "1920x1080@143.854996"
    }
    output "DP-2" {
        scale 1.000000
        transform "normal"
        position x=0 y=-1080
        mode "1920x1080@143.854996"
    }
    output "DSI-1" {
        scale 1.000000
        transform "270"
        position x=0 y=0
        mode "1200x1920@50.002000"
    }
    output "HDMI-A-1" {
        off
        transform "normal"
    }
    output "eDP-1" {
        scale 1.000000
        transform "normal"
        position x=0 y=0
        mode "1920x1080@144.005005"
    }

    spawn-at-startup "footserver"
    spawn-at-startup "signal-desktop" "--start-in-tray"
    spawn-at-startup "wl-paste" "--type" "text" "--watch" "cliphist" "store"
    spawn-at-startup "wl-paste" "--type" "image" "--watch" "cliphist" "store"
    spawn-at-startup "swaybg" "-m" "fill" "-i" "${osConfig.stylix.image}"
    spawn-at-startup "dispwin" "${
      if osConfig.networking.hostName == "victus" then "/etc/color-profile.icm" else "-L"
    }"

    prefer-no-csd

    layout {
        focus-ring {
            width 4
            active-color "#${theme."primary-pale"}"
            inactive-color "#${theme."grey-dark"}"
        }

        border {
            off
            width 4
            active-color "#${theme.primary}"
            inactive-color "#${theme."grey-dark"}"
        }

        gaps 16
    }

    window-rule {
        geometry-corner-radius 12
        clip-to-geometry true
    }

    binds {
        Mod+W { spawn "pkill" "-SIGUSR1" "waybar"; }
        Mod+Ctrl+W { spawn "pkill" "-SIGUSR1" "wlsunset"; }
    Mod+B { spawn "nu" "-c" "cd ~/Nextcloud; ls skripte/**/* | append (ls books/**/*) | append (ls ostalo) | append (ls cheatsheets) | where type == file | $in.name | str join \"\\n\" | fuzzel -d | if ($in | is-not-empty) {zathura $in}"; }

        Mod+Tab { toggle-overview; }
        Ctrl+Alt+Delete { quit; }

        Mod+S { screenshot; }
        Mod+Ctrl+S { screenshot-screen; }
        Mod+Alt+S { screenshot-window; }

        Mod+J { focus-workspace-down; }
        Mod+K { focus-workspace-up; }
        Mod+Ctrl+J { move-column-to-workspace-down; }
        Mod+Ctrl+K { move-column-to-workspace-up; }

        Mod+Home { focus-column-first; }
        Mod+End { focus-column-last; }
        Mod+Ctrl+Home { move-column-to-first; }
        Mod+Ctrl+End { move-column-to-last; }

        Mod+Shift+H { focus-monitor-left; }
        Mod+Shift+J { focus-monitor-down; }
        Mod+Shift+K { focus-monitor-up; }
        Mod+Shift+L { focus-monitor-right; }

        Mod+Shift+Ctrl+H { move-column-to-monitor-left; }
        Mod+Shift+Ctrl+J { move-column-to-monitor-down; }
        Mod+Shift+Ctrl+K { move-column-to-monitor-up; }
        Mod+Shift+Ctrl+L { move-column-to-monitor-right; }
        Mod+Ctrl+H { move-column-left; }
        Mod+Ctrl+L { move-column-right; }

        Mod+BracketLeft { consume-or-expel-window-left; }
        Mod+BracketRight { consume-or-expel-window-right; }

        Mod+Comma { consume-window-into-column; }
        Mod+Period { expel-window-from-column; }

        Mod+R { switch-preset-column-width; }
        Mod+Shift+R { switch-preset-window-height; }
        Mod+Ctrl+R { reset-window-height; }
        Mod+F { maximize-column; }
        Mod+Shift+F { fullscreen-window; }

        Mod+Shift+Slash { show-hotkey-overlay; }
        Mod+Return { spawn "footclient"; }
        Mod+Q { close-window; }
        Mod+N { spawn "footclient" "yazi"; }
        Mod+D { spawn "fuzzel"; }
        Mod+P { toggle-window-floating; }
        Mod+E { spawn "bemoji" "-cn"; }
        Mod+Z { spawn "sh" "-c" "cliphist list | fuzzel -d | cliphist decode | wl-copy"; }
        Mod+F1 { spawn "swaylock"; }
        Mod+Shift+N { spawn "swaync-client" "-t"; }
        Mod+O { spawn "firefox"; }
        Mod+Alt+O { spawn "firefox" "https://search.nixos.org/options"; }
        Mod+Alt+P { spawn "firefox" "https://search.nixos.org/packages"; }
        Mod+Alt+G { spawn "firefox" "https://gemini.google.com"; }
        
        Mod+Shift+W { spawn "looking-glass-client" "-f" "/dev/kvmfr0" "-m" "KEY_INSERT" "-F" "-T"; }
        Mod+Shift+V { spawn "blueman-manager"; }
        Mod+V { spawn "pavucontrol"; }
        Mod+H { focus-column-left; }
        Mod+L { focus-column-right; }

        Mod+1 { focus-workspace 1; }
        Mod+2 { focus-workspace 2; }
        Mod+3 { focus-workspace 3; }
        Mod+4 { focus-workspace 4; }
        Mod+5 { focus-workspace 5; }
        Mod+6 { focus-workspace 6; }
        Mod+7 { focus-workspace 7; }
        Mod+8 { focus-workspace 8; }
        Mod+9 { focus-workspace 9; }
        Mod+0 { focus-workspace 10; }

        Mod+Shift+1 { move-window-to-workspace 1; }
        Mod+Shift+2 { move-window-to-workspace 2; }
        Mod+Shift+3 { move-window-to-workspace 3; }
        Mod+Shift+4 { move-window-to-workspace 4; }
        Mod+Shift+5 { move-window-to-workspace 5; }
        Mod+Shift+6 { move-window-to-workspace 6; }
        Mod+Shift+7 { move-window-to-workspace 7; }
        Mod+Shift+8 { move-window-to-workspace 8; }
        Mod+Shift+9 { move-window-to-workspace 9; }
        Mod+Shift+0 { move-window-to-workspace 10; }

        XF86AudioRaiseVolume { spawn "wpctl" "set-volume" "-l" "1" "@DEFAULT_AUDIO_SINK@" "5%+"; }
        XF86AudioLowerVolume { spawn "wpctl" "set-volume" "@DEFAULT_AUDIO_SINK@" "5%-"; }
        XF86AudioMute { spawn "wpctl" "set-mute" "@DEFAULT_AUDIO_SINK@" "toggle"; }
        XF86AudioMicMute { spawn "wpctl" "set-mute" "@DEFAULT_AUDIO_SOURCE@" "toggle"; }
        XF86MonBrightnessUp { spawn "brightnessctl" "s" "10%+"; }
        XF86MonBrightnessDown { spawn "brightnessctl" "s" "10%-"; }
        XF86AudioNext { spawn "playerctl" "next"; }
        XF86AudioPause { spawn "playerctl" "play-pause"; }
        XF86AudioPlay { spawn "playerctl" "play-pause"; }
        XF86AudioPrev { spawn "playerctl" "previous"; }
    }
  '';
  programs.niri.package = pkgs-unstable.niri;

  home.packages = with pkgs; [
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
  ];
}
