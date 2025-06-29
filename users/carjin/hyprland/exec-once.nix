{
  wayland.windowManager.hyprland.settings = {
    exec-once = [

      "uwsm app -- footserver"
      "uwsm app -- vesktop"
      "uwsm app -- signal-desktop --start-in-tray"
      # "uwsm app -- thunderbird --headless"
      "[workspace special] uwsm app -- footclient"
      # Clipboard Manager
      "uwsm app -- wl-paste --type text --watch cliphist store #Stores only text data"
      "uwsm app -- wl-paste --type image --watch cliphist store #Stores only image data"
      # Mouse
      "hyprctl setcursor DMZ-Black 10"
    ];

  };
}
