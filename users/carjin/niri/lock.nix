{ pkgs, ... }:

{
  programs.swaylock = {
    enable = true;
    package = pkgs.swaylock-effects;
    settings = {
      screenshots = true;
      clock = true;
      indicator = true;
      indicator-radius = 400;
      indicator-thickness = 20;
      effect-blur = "8x3";
      fade-in = 0.5;
      datestr = "%B %d, %Y";
      timestr = "%I:%M %p";
      font-size = 100;
    };
  };
}
