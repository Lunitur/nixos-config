
{ pkgs, ... }:

{
  services.wlsunset = {
    enable = true;
    sunrise = "06:00";
    sunset = "19:00";
    temperature = {
      day = 6500;
      night = 3500;
    };
  };
}
