{
  wayland.windowManager.hyprland.settings = {
    windowrule = [
      "workspace 2, firefox"
      "workspace 3, thunar"
      "workspace 4, code"
      "workspace 5, vesktop"
      "workspace 5, discord"
      "workspace 5, Element"
      "workspace 5, Signal"
      "workspace 6, looking-glass-client"
      "workspace 7, mpv"
      "workspace 8, Thunderbird"
      "workspace 9, deluge"

      "float, yad"
      "float, blueman-manager"
      "size 40% 30%, blueman-manager"
      "float, pavucontrol"
      "size 40% 30%, pavu-control"
      "float, xfce4-taskmanager"
      # "size 40% 30%, xfce4-taskmanager"
      "float, Bluetooth-sendto"
      "size 40% 30%, Bluetooth-sendto"
      # Set floating for window roles and types
      "float, title:File Operation Progress"
      "size 40% 30%, title:File Operation Progress"
      "float, title: Save File"
      "size 40% 30%, title: Save File"
      # Inhibit idle for specific apps
      "idleinhibit fullscreen, firefox"
      "idleinhibit fullscreen, mpv"
    ];
  };
}
