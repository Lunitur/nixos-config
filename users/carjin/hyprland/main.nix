{ pkgs, ... }:
let
  theme = import ../theme;
in
{
  wayland.windowManager.hyprland = {
    enable = true;
    systemd.enable = false;

    settings = {
      # env = [
      #   "NIXOS_OZONE_WL,1"
      #   "XDG_CURRENT_DESKTOP,Hyprland"
      #   "XDG_SESSION_TYPE,wayland"
      #   "XDG_SESSION_DESKTOP,Hyprland"
      #   "QT_QPA_PLATFORM,wayland"
      #   "XDG_SCREENSHOTS_DIR,$HOME/screens"
      # ];

      monitor = [
        "eDP-1, 1920x1080@144.005005, 1920x0, 1.00"
        "DP-1, 1920x1080@143.854996, 0x0, 1.00"
        "DP-2, 1920x1080@143.854996, 0x0, 1.00"
        "DSI-1, 1200x1920@50.00200, 0x0, 1.00, transform, 3"
        "HDMI-A-1, disable"
        #  "DP-1, 1920x1080@143.854996, 0x0, 1.00",
        #  "HDMI-1, 1920x1080@143.854996, 0x0, 1.00",
        # "preferred,auto,1"
      ];

      exec-once = [
        "uwsm app -- waybar"
        "uwsm app -- wl-paste --type text --watch cliphist store"
        "uwsm app -- wl-paste --type image --watch cliphist store"
      ];

      general = {
        gaps_in = 6;
        gaps_out = 12;

        border_size = 2;

        "col.active_border" = "rgba(${theme.primary}FF)";

        resize_on_border = true;

        allow_tearing = false;
        layout = "master";
      };

      decoration = {
        rounding = 10;

        active_opacity = 1;
        inactive_opacity = 0.75;

        shadow = {
          enabled = true;
          ignore_window = true;
          range = 20;
          render_power = 5;
          color = "rgba(${theme.primary}FF)";
          color_inactive = "rgba(${theme.background}FF)";
        };

        blur = {
          enabled = true;
          size = 6;
          passes = 3;
          new_optimizations = true;
          ignore_opacity = true;
          noise = 0.0117;
          contrast = 1.2;
          xray = false;
          brightness = 1;
        };
      };

      animations = {
        enabled = false;
      };

      input = {
        kb_layout = "hr";
        kb_variant = "us";
        kb_options = "caps:escape";
        numlock_by_default = true;
        follow_mouse = 1;

        touchpad = {
          natural_scroll = true;
          tap-to-click = true;
          disable_while_typing = true;
        };

        touchdevice = {
          transform = 3;
        };
      };

      gestures = {
        workspace_swipe = true;
        workspace_swipe_invert = false;
        workspace_swipe_forever = true;
      };

      dwindle = {
        pseudotile = true;
        preserve_split = true;
      };

      master = {
        new_status = "slave";
        new_on_top = true;
        mfact = 0.5;
      };

      misc = {
        force_default_wallpaper = 0;
        disable_hyprland_logo = true;
      };

      windowrule = [
        "bordersize 0, floating:0, onworkspace:w[t1]"

        "float,class:(mpv)|(imv)|(showmethekey-gtk)"
        "move 990 60,size 900 170,pin,noinitialfocus,class:(showmethekey-gtk)"
        "noborder,nofocus,class:(showmethekey-gtk)"

        "suppressevent maximize, class:.*"
        "nofocus,class:^$,title:^$,xwayland:1,floating:1,fullscreen:0,pinned:0"

        "opacity 0.0 override, class:^(xwaylandvideobridge)$"
        "noanim, class:^(xwaylandvideobridge)$"
        "noinitialfocus, class:^(xwaylandvideobridge)$"
        "maxsize 1 1, class:^(xwaylandvideobridge)$"
        "noblur, class:^(xwaylandvideobridge)$"
        "nofocus, class:^(xwaylandvideobridge)$"
      ];
    };
  };

  home.packages = with pkgs; [
    networkmanagerapplet
    wlrctl
    wlr-randr
    slurp # screenshot functionality
    wl-clipboard # wl-copy and wl-paste for copy/paste from stdin / stdout
    pamixer
    wofi
    pavucontrol
    alsa-utils
    brightnessctl
    wlsunset
    yad
    loupe
    cliphist
    swappy
    grimblast
    jq
    hyprsunset
    conky
  ];
}
