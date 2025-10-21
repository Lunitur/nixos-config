{
  programs.niri.settings = {
    spawn-at-startup = [
      { sh = "footserver"; }
      { sh = "signal-desktop --start-in-tray"; }
      { sh = "wl-paste --type text --watch cliphist store"; }
      { sh = "wl-paste --type image --watch cliphist store"; }
      { sh = "swaybg -i /home/carjin/nixos/users/carjin/wallpapers/desktop6.png"; }
    ];
  };
}
