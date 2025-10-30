let
  colors = import ../theme;
in
''
  * {
    border: none;
    border-radius: 0px;
    font-family: "JetBrains Mono";
    font-weight: bold;
    font-size: 16px;
    min-height: 0;
    color: #${colors.primary-pale};
    padding: 0px 5px;
  }

  window#waybar {
    background: transparent;
  }

  #workspaces {
    background: #${colors.mantle}; 
    padding: 5px;
    border-radius: 10px;
    margin: 12px 5px 0px 5px;
  }

  #workspaces button {
    background: transparent;
    border-radius: 20px;
  }

  #workspaces button:hover {
    background: #${colors.grey};
  }

  #workspaces button.active {
    background: #${colors.primary};
  }

  #workspaces button.active label {
    color: #${colors.mantle};
  }


  #taskbar {
    background: #${colors.mantle}; 
    padding: 5px;
    border-radius: 10px;
    margin: 12px 5px 0px 5px;
  }

  #taskbar button {
    background: transparent;
    border-radius: 20px;
  }

  #taskbar button:hover {
    background: #${colors.grey};
  }

  #taskbar button.active {
    background: #${colors.primary};
  }

  #taskbar button.active label {
    color: #${colors.mantle};
  }

  #taskbar {
    margin-left: 7px;
  }


  #clock, #temperature, #battery, #pulseaudio, #tray, #custom-power, #custom-gpu, #memory, #cpu {
    background: #${colors.mantle};
    border-radius: 10px;
    padding: 0px 10px;
    margin: 12px 5px 0px 5px;
    transition: all 0.2s ease-in-out;
  }

  #tray {
    margin-right: 7px;
  }

  #clock:hover,
  #battery:hover,
  #pulseaudio:hover,
  #tray:hover,
  #custom-power:hover,
  #memory:hover,
  #temperature:hover,
  #cpu:hover {
    background: #${colors.primary};
    color: #${colors.mantle};
  }
''
