{
  pkgs,
  lib,
  osConfig,
  ...
}:
let
  gpu-check = pkgs.writeShellScript "gpu-checker" ''
    #!/usr/bin/env bash
    set -e
    if lsmod | grep -q "^nvidia "; then
      echo '{"text": "NVIDIA", "class": "nvidia"}'
    else
      echo '{"text": "AMD", "class": "amd"}'
    fi
  '';

  is-victus = osConfig.networking.hostName == "victus";
  is-minibook = osConfig.networking.hostName == "minibook";
in
{
  stylix.targets.waybar.enable = false;
  programs.waybar = {
    systemd.enable = true;
    enable = true;
    settings = {
      mainBar = {
        mode = lib.mkIf is-minibook "hide";
        modifier-reset = lib.mkIf is-minibook "release";
        layer = "top";
        position = "top";
        height = 40;
        modules-left = [
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

        "niri/workspaces" = {
          all-outputs = false;
          format = "{name}";
        };

        "wlr/taskbar" = {
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
          format-icons = [ "" "" "" "" "" ];
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
            "default" = [ "󰕿" "󰖀" ];
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
          format-icons = [ "" "" "" "" "" ];
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
          on-click = "systemctl poweroff";
        };

        "tray" = {
          icon-size = 14;
          spacing = 1;
        };
      };
    };
  };
  home.file.".config/waybar/style.css".text = import ./_style.nix;
}
