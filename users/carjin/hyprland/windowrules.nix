{
  wayland.windowManager.hyprland.settings = {
    windowrule = [
      # "workspace 2, firefox"
      # "workspace 3, thunar"
      # "workspace 4, code"
      "workspace 5, class:vesktop"
      "workspace 5, class:discord"
      "workspace 5, class:Element"
      "workspace 5, class:signal"
      "workspace 6, class:looking-glass-client"
      "workspace 7, class:mpv"
      "workspace 8, class:Thunderbird"
      "workspace 9, class:deluge"

      "float, class:yad"
      "float, title:Bluetooth devices"
      "size 40% 30%, title:Bluetooth devices"
      "float, title:Volume Control"
      "size 40% 30%, title:Volume Control"
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

      # "fullscreen, title:.*[Cc]heatsheets.*"
      "float, title:.*[Cc]heatsheets.*"
      "size 90% 90%, title:.*[Cc]heatsheets.*"
      "center, title:.*[Cc]heatsheets.*"
      "opacity 0.9 0.9, title:.*[Cc]heatsheets.*"
    ];
  };
}
