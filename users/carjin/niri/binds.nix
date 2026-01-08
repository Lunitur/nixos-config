{
  programs.niri.settings = {
    binds = {
      "Mod+W".action.spawn = [
        "pkill"
        "-SIGUSR1"
        "waybar"
      ];
      "Mod+Ctrl+W".action.spawn = [
        "pkill"
        "-SIGUSR1"
        "wlsunset"
      ];
      "Mod+B".action.spawn = [
        "nu"
        "-c"
        "cd ~/Nextcloud; ls skripte/**/* | append (ls books/**/*) | append (ls ostalo) | append (ls cheatsheets) | where type == file | $in.name | str join \"\\n\" | fuzzel -d | if ($in | is-not-empty) {zathura $in}"
      ];

      "Mod+Shift+Tab".action.toggle-overview = [ ];
      "Ctrl+Alt+Delete".action.quit = [ ];

      "Print".action.screenshot = [ ];
      "Ctrl+Print".action.screenshot-screen = [ ];
      "Alt+Print".action.screenshot-window = [ ];

      "Mod+Shift+Page_Down".action.move-workspace-down = [ ];
      "Mod+Shift+Page_Up".action.move-workspace-up = [ ];
      "Mod+Shift+U".action.move-workspace-down = [ ];
      "Mod+Shift+I".action.move-workspace-up = [ ];

      "Mod+Page_Down".action.focus-workspace-down = [ ];
      "Mod+Page_Up".action.focus-workspace-up = [ ];
      "Mod+U".action.focus-workspace-down = [ ];
      "Mod+I".action.focus-workspace-up = [ ];
      "Mod+Ctrl+Page_Down".action.move-column-to-workspace-down = [ ];
      "Mod+Ctrl+Page_Up".action.move-column-to-workspace-up = [ ];
      "Mod+Ctrl+U".action.move-column-to-workspace-down = [ ];
      "Mod+Ctrl+I".action.move-column-to-workspace-up = [ ];

      "Mod+Home".action.focus-column-first = [ ];
      "Mod+End".action.focus-column-last = [ ];
      "Mod+Ctrl+Home".action.move-column-to-first = [ ];
      "Mod+Ctrl+End".action.move-column-to-last = [ ];

      "Mod+Shift+Left".action.focus-monitor-left = [ ];
      "Mod+Shift+Down".action.focus-monitor-down = [ ];
      "Mod+Shift+Up".action.focus-monitor-up = [ ];
      "Mod+Shift+Right".action.focus-monitor-right = [ ];
      "Mod+Shift+H".action.focus-monitor-left = [ ];
      "Mod+Shift+J".action.focus-monitor-down = [ ];
      "Mod+Shift+K".action.focus-monitor-up = [ ];
      "Mod+Shift+L".action.focus-monitor-right = [ ];

      "Mod+Shift+Ctrl+Left".action.move-column-to-monitor-left = [ ];
      "Mod+Shift+Ctrl+Down".action.move-column-to-monitor-down = [ ];
      "Mod+Shift+Ctrl+Up".action.move-column-to-monitor-up = [ ];
      "Mod+Shift+Ctrl+Right".action.move-column-to-monitor-right = [ ];
      "Mod+Shift+Ctrl+H".action.move-column-to-monitor-left = [ ];
      "Mod+Shift+Ctrl+J".action.move-column-to-monitor-down = [ ];
      "Mod+Shift+Ctrl+K".action.move-column-to-monitor-up = [ ];
      "Mod+Shift+Ctrl+L".action.move-column-to-monitor-right = [ ];
      "Mod+Ctrl+Left".action.move-column-left = [ ];
      "Mod+Ctrl+Down".action.move-window-down = [ ];
      "Mod+Ctrl+Up".action.move-window-up = [ ];
      "Mod+Ctrl+Right".action.move-column-right = [ ];
      "Mod+Ctrl+H".action.move-column-left = [ ];
      "Mod+Ctrl+J".action.move-window-down = [ ];
      "Mod+Ctrl+K".action.move-window-up = [ ];
      "Mod+Ctrl+L".action.move-column-right = [ ];

      "Mod+BracketLeft".action.consume-or-expel-window-left = [ ];
      "Mod+BracketRight".action.consume-or-expel-window-right = [ ];

      "Mod+Comma".action.consume-window-into-column = [ ];
      "Mod+Period".action.expel-window-from-column = [ ];

      "Mod+R".action.switch-preset-column-width = [ ];
      # "Mod+R".action.spawn.switch-preset-column-width-back = [];
      "Mod+Shift+R".action.switch-preset-window-height = [ ];
      "Mod+Ctrl+R".action.reset-window-height = [ ];
      "Mod+F".action.maximize-column = [ ];
      "Mod+Shift+F".action.fullscreen-window = [ ];

      "Mod+Tab".action.focus-workspace-previous = [ ];
      "Mod+Shift+Slash".action.show-hotkey-overlay = [ ];
      "Mod+Return".action.spawn = [ "footclient" ];
      "Mod+Q".action.close-window = [ ];
      # "Mod+Shift+Q".action.exit = [ ];
      "Mod+N".action.spawn = [
        "footclient"
        "yazi"
      ];
      # "Mod+F".action.fullscreen = [ ];
      "Mod+D".action.spawn = [ "fuzzel" ];
      "Mod+P".action.toggle-window-floating = [ ];
      "Mod+E".action.spawn = [
        "bemoji"
        "-cn"
      ];
      "Mod+Z".action.spawn = [
        "sh"
        "-c"
        "cliphist list | fuzzel -d | cliphist decode | wl-copy"
      ];
      "Mod+F1".action.spawn = [ "swaylock" ];
      # "Mod+F2".action.spawn = [ "hyprpicker -an" ];
      "Mod+Shift+N".action.spawn = [
        "swaync-client"
        "-t"
      ];
      "Mod+O".action.spawn = [ "firefox" ];
      "Mod+Alt+O".action.spawn = [
        "firefox"
        "https://search.nixos.org/options"
      ];
      "Mod+Alt+P".action.spawn = [
        "firefox"
        "https://search.nixos.org/packages"
      ];
      "Mod+Alt+G".action.spawn = [
        "firefox"
        "https://gemini.google.com"
      ];
      # "Mod+B".action.spawn = [
      #   "sh"
      #   "nu -c 'cd ~/Nextcloud; ls skripte/**/* | append (ls books/**/*) | append (ls ostalo) | where type == file | $in.name | str join \"\n\" | fuzzel -d | if ($in | is-not-empty) {zathura $in}'"
      # ];
      # "Mod+C".action.spawn = [
      #   "sh"
      #   "nu -c 'cd ~/Nextcloud/cheatsheets; ls | $in.name | str join \"\n\" | fuzzel -d | if ($in | is-not-empty) {zathura $in}'"
      # ];
      "Mod+Shift+W".action.spawn = [
        "looking-glass-client"
        "-f"
        "/dev/kvmfr0"
        "-m"
        "KEY_INSERT"
        "-F"
        "-T"
      ];
      "Mod+Shift+V".action.spawn = [ "blueman-manager" ];
      "Mod+V".action.spawn = [ "pavucontrol" ];
      "Mod+H".action.focus-column-left = [ ];
      "Mod+L".action.focus-column-right = [ ];
      "Mod+K".action.focus-window-up = [ ];
      "Mod+J".action.focus-window-down = [ ];
      # "Mod+Shift+H".action.move-window-to-column-left = [ ];
      # "Mod+Shift+L".action.move-window-to-column-right = [ ];
      # "Mod+Shift+K".action.move-window-up = [ ];
      # "Mod+Shift+J".action.move-window-down = [ ];
      # "Mod+Tab".action.focus-last-workspace = [ ];
      "Mod+1".action.focus-workspace = [ 1 ];
      "Mod+2".action.focus-workspace = [ 2 ];
      "Mod+3".action.focus-workspace = [ 3 ];
      "Mod+4".action.focus-workspace = [ 4 ];
      "Mod+5".action.focus-workspace = [ 5 ];
      "Mod+6".action.focus-workspace = [ 6 ];
      "Mod+7".action.focus-workspace = [ 7 ];
      "Mod+8".action.focus-workspace = [ 8 ];
      "Mod+9".action.focus-workspace = [ 9 ];
      "Mod+0".action.focus-workspace = [ 10 ];
      "Mod+Shift+1".action.move-window-to-workspace = [ 1 ];
      "Mod+Shift+2".action.move-window-to-workspace = [ 2 ];
      "Mod+Shift+3".action.move-window-to-workspace = [ 3 ];
      "Mod+Shift+4".action.move-window-to-workspace = [ 4 ];
      "Mod+Shift+5".action.move-window-to-workspace = [ 5 ];
      "Mod+Shift+6".action.move-window-to-workspace = [ 6 ];
      "Mod+Shift+7".action.move-window-to-workspace = [ 7 ];
      "Mod+Shift+8".action.move-window-to-workspace = [ 8 ];
      "Mod+Shift+9".action.move-window-to-workspace = [ 9 ];
      "Mod+Shift+0".action.move-window-to-workspace = [ 10 ];
      "XF86AudioRaiseVolume".action.spawn = [
        "wpctl"
        "set-volume"
        "-l"
        "1"
        "@DEFAULT_AUDIO_SINK@"
        "5%+"
      ];
      "XF86AudioLowerVolume".action.spawn = [
        "wpctl"
        "set-volume"
        "@DEFAULT_AUDIO_SINK@"
        "5%-"
      ];
      "XF86AudioMute".action.spawn = [
        "wpctl"
        "set-mute"
        "@DEFAULT_AUDIO_SINK@"
        "toggle"
      ];
      "XF86AudioMicMute".action.spawn = [
        "wpctl"
        "set-mute"
        "@DEFAULT_AUDIO_SOURCE@"
        "toggle"
      ];
      "XF86MonBrightnessUp".action.spawn = [
        "brightnessctl"
        "s"
        "10%+"
      ];
      "XF86MonBrightnessDown".action.spawn = [
        "brightnessctl"
        "s"
        "10%-"
      ];
      "XF86AudioNext".action.spawn = [
        "playerctl"
        "next"
      ];
      "XF86AudioPause".action.spawn = [
        "playerctl"
        "play-pause"
      ];
      "XF86AudioPlay".action.spawn = [
        "playerctl"
        "play-pause"
      ];
      "XF86AudioPrev".action.spawn = [
        "playerctl"
        "previous"
      ];
    };
  };
}
