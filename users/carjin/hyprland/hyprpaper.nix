{ config, ... }:
{
  services.hyprpaper = {
    enable = true;
    settings = {
      ipc = "on";
      # splash = false;
      # splash_offset = 2.0;

      # preload = [
      #   "Pictures/desktop.jpg"
      # ];

      # wallpaper = [
      #   "DP-1,Pictures/desktop.jpg"
      #   "DP-2,Pictures/desktop.jpg"
      # ];
    };
  };
}
