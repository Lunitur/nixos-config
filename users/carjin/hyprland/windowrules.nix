{
  wayland.windowManager.hyprland.settings = {
    windowrule = [
      # "workspace 2, firefox"
      # "workspace 3, thunar"
      # "workspace 4, code"
      "workspace 5, class:vesktop"
      "workspace 5, class:discord"
      "workspace 5, class:Element"
      "workspace 5, class:Signal"
      "workspace 6, class:looking-glass-client"
      "workspace 7, class:mpv"
      "workspace 8, class:Thunderbird"
      "workspace 9, class:deluge"

      "float, class:yad"
      "float, class:blueman-manager"
      "size 40% 30%, class:blueman-manager"
      "float, class:pavucontrol"
      "size 40% 30%, class:pavu-control"
      "float, class:xfce4-taskmanager"
      # "size 40% 30%, xfce4-taskmanager"
      "float, class:Bluetooth-sendto"
      "size 40% 30%, class:Bluetooth-sendto"
      # Set floating for window roles and types
      "float, title:File Operation Progress"
      "size 40% 30%, title:File Operation Progress"
      "float, title: Save File"
      "size 40% 30%, title: Save File"
      # Inhibit idle for specific apps
      "idleinhibit fullscreen, class:firefox"
      "idleinhibit fullscreen, class:mpv"
    ];
  };
}
