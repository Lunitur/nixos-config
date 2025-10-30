{
  pkgs,
  lib,
  osConfig,
  ...
}:
let
  gpu-check = pkgs.writeShellScript "gpu-checker" ''
    #!/usr/bin/env bash
    # Set -e to exit immediately if a command exits with a non-zero status.
    set -e

    # Check if the 'nvidia' kernel module is loaded.
    # lsmod lists loaded kernel modules.
    # grep -q "^nvidia " searches for a line starting with "nvidia ".
    # The -q flag makes grep quiet, so it doesn't output anything,
    # it just sets its exit code based on whether a match was found.
    if lsmod | grep -q "^nvidia "; then
      # If the nvidia module is found, output a JSON string for nvidia.
      echo '{"text": "NVIDIA", "class": "nvidia"}'
    else
      # Otherwise, output a JSON string for amd (or any non-nvidia setup).
      echo '{"text": "AMD", "class": "amd"}'
    fi
  '';

  is-victus = osConfig.networking.hostName == "victus";
  is-minibook = osConfig.networking.hostName == "minibook";
in
{
  programs.waybar = {
    systemd.enable = true;
    enable = true;
    settings = {
      mainBar = {
        start_hidden = lib.mkIf is-minibook true;
        mode = lib.mkIf is-minibook "hide";
        modifier-reset = lib.mkIf is-minibook "release";
        layer = "top";
        position = "top";
        height = 40;
        margin-top = 0;
        margin-bottom = 0;
        margin-left = 0;
        margin-right = 0;
        modules-left = [
          # "niri/workspaces"
          "wlr/taskbar"
        ];
        modules-center = [ ];
        modules-right = lib.optional is-victus "custom/gpu" ++ [
          "memory"
          "temperature"
          "pulseaudio"
          "battery"
          "clock"
          "custom/power"
          "tray"
        ];

        # "hyprland/workspaces" = {
        #   disable-scroll = true;
        #   show-special = true;
        #   special-visible-only = true;
        #   all-outputs = false;
        #   format = "{id}";
        #   persistent-workspaces = {
        #     "*" = 3;
        #   };
        # };

        "niri/workspaces" = {
          # disable-scroll = true;
          # show-special = true;
          # special-visible-only = true;
          all-outputs = false;
          format = "{name}";
          # persistent-workspaces = {
          #   "*" = 3;
          # };
        };

        "wlr/taskbar" = {
          # "all-outputs"= true;
          # "format"= "{icon} {title} {short_state}";
          format = "{icon}";
          tooltip-format = "{title} | {app_id}";
          on-click = "activate";
          on-click-middle = "close";
          on-click-right = "fullscreen";
        };

        temperature = {
          hwmon-path = "/sys/class/hwmon/hwmon5/temp1_input";
          critical-threshold = 75;
          interval = 5;
          format = "{icon} {temperatureC}°";
          tooltip = false;
          format-icons = [
            ""
            ""
            ""
            ""
            ""
          ];
        };

        cpu = {
          format = " {usage: >3}%";
          on-click = "foot -e htop";
        };

        memory = {
          interval = 15;
          format = "   {used:0.1f}G/{total:0.1f}G";
          tooltip = false;
          on-click = "xfce4-taskmanager";
        };

        clock = {
          format = " {:%a, %d %b, %I:%M %p}";
          tooltip = "true";
          tooltip-format = "{calendar}";
          format-alt = "{:%I:%M %p}";
        };

        "pulseaudio" = {
          format = "{icon} {volume}%";
          format-bluetooth = "{icon} {volume}% 󰂯";
          format-muted = "󰝟";
          format-icons = {
            "headphones" = "󰋋";
            "handsfree" = "󰋎";
            "headset" = "󰋎";
            "phone" = "󰣏";
            "portable" = "󰣏";
            "car" = "󰄜";
            "default" = [
              "󰕿"
              "󰖀"
            ];
          };
          on-click = "pavucontrol";
        };

        "battery" = {
          states = {
            warning = 30;
            critical = 1;
          };
          format = "{icon} {capacity}%";
          format-charging = " {capacity}%";
          format-alt = "{time} {icon}";
          format-icons = [
            ""
            ""
            ""
            ""
            ""
          ];
        };

        "custom/gpu" = {
          format = "{}";
          exec = gpu-check;
          return-type = "json";
          interval = 10;
        };

        "custom/power" = {
          format = "⏻";
          tooltip = true;
          tooltip-format = "Power Menu";
          # on-click = "rofi -show power-menu -modi power-menu:rofi-power-menu";
          on-click = "systemctl poweroff";
        };

        "tray" = {
          icon-size = 14;
          spacing = 1;
        };
      };
    };
  };
  home.file.".config/waybar/style.css".text = import ./style.nix;
}
