{ osConfig, lib, ... }:
{
  wayland.windowManager.hyprland.settings = {
    bind = [
      "SUPER,       Return, exec, uwsm app -- footclient"
      "SUPER,       Q, killactive,"
      "SUPER SHIFT, Q, exit,"
      "SUPER,       N, exec, uwsm app -- thunar"
      "SUPER,       F, fullscreen"
      "SUPER,       D, exec, fuzzel"
      "SUPER,       P, pin,"
      # "SUPER,       S, togglesplit,"
      "SUPER,       E, exec, bemoji -cn"
      "SUPER,       C, exec, cliphist list | fuzzel -d | cliphist decode | wl-copy"
      # "SUPER,       B, exec, pkill -SIGUSR2 waybar"
      # "SUPER SHIFT, B, exec, pkill -SIGUSR1 waybar"
      "SUPER,       F1, exec, loginctl lock-session"
      "SUPER,       F2, exec, hyprpicker -an"
      "SUPER SHIFT, N, exec, uwsm app -- swaync-client -t"
      "SUPER,       O, exec, uwsm app -- firefox"
      "SUPER ALT, O, exec, uwsm app -- firefox https://search.nixos.org/options"
      "SUPER ALT, P, exec, uwsm app -- firefox https://search.nixos.org/packages"

      "SUPER,       B, exec, nu -c 'cd ~/Nextcloud; ls skripte | append (ls books) | $in.name | str join \"\\n\" | fuzzel -d | if ($in | is-not-empty) {zathura $in}'"
      "SUPER SHIFT, C, exec, nu -c 'cd ~/Nextcloud/cheatsheets; ls | $in.name | str join \"\\n\" | fuzzel -d | if ($in | is-not-empty) {zathura $in}'"
      # "SUPER, C, exec, uwsm app -- nwg-clipman"
      "SUPER, W, exec, uwsm app -- looking-glass-client -f /dev/kvmfr0 -m KEY_INSERT -F -T"
      "SUPER, V, exec, uwsm app -- pavucontrol"
      "SUPER, M, movetoworkspace, special"
      "SUPER SHIFT, M, exec, brightnessctl s 1"
      "SUPER SHIFT, 36, togglespecialworkspace"

      "SUPER, S, exec, uwsm app -- grimblast --notify --freeze copysave area"

      # "SUPER SHIFT, S, exec, uwsm app -- grim -g \"$(slurp)\" - | swappy -f -"
      # Moving focus
      "SUPER, h, movefocus, l"
      "SUPER, l, movefocus, r"
      "SUPER, k, movefocus, u"
      "SUPER, j, movefocus, d"

      # Moving windows
      "SUPER SHIFT, h,  swapwindow, l"
      "SUPER SHIFT, l,  swapwindow, r"
      "SUPER SHIFT, k,  swapwindow, u"
      "SUPER SHIFT, j,  swapwindow, d"

      # Resizeing windows                   X  Y
      "SUPER     , r,  submap, resize"

      "SUPER CTRL, h,  resizeactive, -60 0"
      "SUPER CTRL, l,  resizeactive,  60 0"
      "SUPER CTRL, k,  resizeactive,  0 -60"
      "SUPER CTRL, j,  resizeactive,  0  60"
      #
      # Scroll windows
      # "SUPER, h,  exec, wlrctl pointer scroll 0 -120"
      # "SUPER, l,  exec, wlrctl pointer scroll 0 120"
      # "SUPER, period,  exec, wlrctl pointer scroll -120 0"
      # "SUPER, comma,  exec, wlrctl pointer scroll 120 0"

      # Switch between current and previous workplace
      "SUPER, TAB, workspace, previous"
      # Switching workspaces
      "SUPER, 1, workspace, 1"
      "SUPER, 2, workspace, 2"
      "SUPER, 3, workspace, 3"
      "SUPER, 4, workspace, 4"
      "SUPER, 5, workspace, 5"
      "SUPER, 6, workspace, 6"
      "SUPER, 7, workspace, 7"
      "SUPER, 8, workspace, 8"
      "SUPER, 9, workspace, 9"
      "SUPER, 0, workspace, 10"

      # Moving windows to workspaces
      "SUPER SHIFT, 1, movetoworkspacesilent, 1"
      "SUPER SHIFT, 2, movetoworkspacesilent, 2"
      "SUPER SHIFT, 3, movetoworkspacesilent, 3"
      "SUPER SHIFT, 4, movetoworkspacesilent, 4"
      "SUPER SHIFT, 5, movetoworkspacesilent, 5"
      "SUPER SHIFT, 6, movetoworkspacesilent, 6"
      "SUPER SHIFT, 7, movetoworkspacesilent, 7"
      "SUPER SHIFT, 8, movetoworkspacesilent, 8"
      "SUPER SHIFT, 9, movetoworkspacesilent, 9"
      "SUPER SHIFT, 0, movetoworkspacesilent, 10"

    ]
    ++ lib.optional (
      osConfig.networking.hostName == "minibook"
    ) "SUPER, SUPER_L, exec, pkill -SIGUSR1 waybar";

    # Move/resize windows with mainMod + LMB/RMB and dragging
    bindm = [
      "SUPER, mouse:272, movewindow"
      "SUPER, mouse:273, resizewindow"
    ];

    # Laptop multimedia keys for volume and LCD brightness
    bindel = [
      ",XF86AudioRaiseVolume,  exec, wpctl set-volume -l 1 @DEFAULT_AUDIO_SINK@ 5%+"
      ",XF86AudioLowerVolume,  exec, wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%-"
      ",XF86AudioMute,         exec, wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle"
      ",XF86AudioMicMute,      exec, wpctl set-mute @DEFAULT_AUDIO_SOURCE@ toggle"
      ",XF86MonBrightnessUp,   exec, brightnessctl s 10%+"
      ",XF86MonBrightnessDown, exec, brightnessctl s 10%-"
    ];

    # Audio playback
    bindl = [
      ", XF86AudioNext,  exec, playerctl next"
      ", XF86AudioPause, exec, playerctl play-pause"
      ", XF86AudioPlay,  exec, playerctl play-pause"
      ", XF86AudioPrev,  exec, playerctl previous"
    ];
  };

  # wayland.windowManager.hyprland.extraConfig = ''
  #   # will start a submap called "resize"
  #   submap=resize

  #   # sets repeatable binds for resizing the active window
  #   binde=,right,resizeactive,50 0
  #   binde=,L,resizeactive,50 0
  #   binde=,left,resizeactive,-50 0
  #   binde=,H,resizeactive,-50 0
  #   binde=,up,resizeactive,0 -50
  #   binde=,K,resizeactive,0 -50
  #   binde=,down,resizeactive,0 50
  #   binde=,J,resizeactive,0 50

  #   # use reset to go back to the global submap
  #   bind=,escape,submap,reset
  # '';
}
