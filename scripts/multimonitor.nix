{ pkgs }:

pkgs.writeShellScriptBin "multimonitor" ''
  #alias xrandr=${pkgs.xorg.xrandr}/bin/xrandr
  # Get the output of xrandr command
  output=$(${pkgs.xorg.xrandr}/bin/xrandr)
      
  # logname="multimonitor-$(date +%s)"
  # echo $output > "/home/carlos/$logname"

  # Check if the output contains "HDMI_1_0"
  if [[ $output == *"eDP-1-0"* ]]; then
    if [[ $output == *"HDMI-0 connected"* ]]; then
      # If yes set secondary monitor as primary
      ${pkgs.xorg.xrandr}/bin/xrandr --output HDMI-0 --primary --mode 1920x1080 -r 144 --output eDP-1-0 --mode 1920x1080 -r 144 --right-of HDMI-0
    elif [[ $output == *"HDMI-0 disconnected"* ]]; then
      ${pkgs.xorg.xrandr}/bin/xrandr --output eDP-1-0 --primary --mode 1920x1080 -r 144
    fi
  elif [[ $output == *"eDP"* ]]; then
    if [[ $output == *"HDMI-1-0 connected"* ]]; then
      # If yes set secondary monitor as primary
      ${pkgs.xorg.xrandr}/bin/xrandr --output HDMI-1-0 --primary --mode 1920x1080 -r 144 --output eDP --mode 1920x1080 -r 144 --right-of HDMI-1-0
    elif [[ $output == *"DisplayPort-1 connected"* ]]; then
      ${pkgs.xorg.xrandr}/bin/xrandr --output DisplayPort-1 --mode 1920x1080 -r 143.85 --primary --left-of eDP
    else
      ${pkgs.xorg.xrandr}/bin/xrandr --output eDP --primary --mode 1920x1080 -r 144
    fi
  fi
''
