
{ pkgs, ... }:

{
  programs.swaylock = {
    enable = true;
    package = pkgs.swaylock-effects;
    settings = {
      screenshots = true;
      clock = true;
      indicator = true;
      indicator-radius = 200;
      indicator-thickness = 20;
      effect-blur = "8x3";
      fade-in = 0.5;
      datestr = "%A, %B %d, %Y";
      timestr = "%I:%M %p";
    };
  };
}
