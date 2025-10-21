{
  programs.niri.settings = {
    binds = {
      "Mod+Return".action.spawn = [ "footclient" ];
      "Mod+Q".action.close-window = [ ];
      # "Mod+Shift+Q".action.exit = [ ];
      "Mod+N".action.spawn = [ "thunar" ];
      # "Mod+F".action.fullscreen = [ ];
      "Mod+D".action.spawn = [ "fuzzel" ];
      "Mod+P".action.toggle-window-floating = [ ];
      "Mod+E".action.spawn = [ "bemoji -cn" ];
      "Mod+Z".action.spawn = [
        "sh"
        "cliphist list | fuzzel -d | cliphist decode | wl-copy"
      ];
      "Mod+F1".action.spawn = [ "loginctl lock-session" ];
      "Mod+F2".action.spawn = [ "hyprpicker -an" ];
      "Mod+Shift+N".action.spawn = [ "swaync-client -t" ];
      "Mod+O".action.spawn = [ "firefox" ];
      "Mod+Alt+O".action.spawn = [
        "firefox"
        "https://search.nixos.org/options"
      ];
      "Mod+Alt+P".action.spawn = [
        "firefox"
        "https://search.nixos.org/packages"
      ];
      "Mod+B".action.spawn = [
        "sh"
        "nu -c 'cd ~/Nextcloud; ls skripte/**/* | append (ls books/**/*) | append (ls ostalo) | where type == file | $in.name | str join \"\n\" | fuzzel -d | if ($in | is-not-empty) {zathura $in}'"
      ];
      "Mod+C".action.spawn = [
        "sh"
        "nu -c 'cd ~/Nextcloud/cheatsheets; ls | $in.name | str join \"\n\" | fuzzel -d | if ($in | is-not-empty) {zathura $in}'"
      ];
      "Mod+W".action.spawn = [ "looking-glass-client -f /dev/kvmfr0 -m KEY_INSERT -F -T" ];
      "Mod+V".action.spawn = [ "pavucontrol" ];
      "Mod+S".action.spawn = [ "grimblast --notify --freeze copysave area" ];
      "Mod+H".action.focus-column-left = [ ];
      "Mod+L".action.focus-column-right = [ ];
      "Mod+K".action.focus-window-up = [ ];
      "Mod+J".action.focus-window-down = [ ];
      # "Mod+Shift+H".action.move-window-to-column-left = [ ];
      # "Mod+Shift+L".action.move-window-to-column-right = [ ];
      "Mod+Shift+K".action.move-window-up = [ ];
      "Mod+Shift+J".action.move-window-down = [ ];
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
