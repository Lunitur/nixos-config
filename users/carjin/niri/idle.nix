{ pkgs, inputs, ... }:

{
  services.swayidle = {
    enable = true;
    events = [
      {
        event = "before-sleep";
        command = "${pkgs.swaylock-effects}/bin/swaylock -f";
      }
      {
        event = "lock";
        command = "${pkgs.swaylock-effects}/bin/swaylock -f";
      }
    ];
    timeouts = [
      {
        timeout = 600;
        command = "${pkgs.brightnessctl}/bin/brightnessctl -s set 10";
        resumeCommand = "${pkgs.brightnessctl}/bin/brightnessctl -r";
      }
      {
        timeout = 150;
        command = "${pkgs.brightnessctl}/bin/brightnessctl -sd rgb:kbd_backlight set 0";
        resumeCommand = "${pkgs.brightnessctl}/bin/brightnessctl -rd rgb:kbd_backlight";
      }
      {
        timeout = 900;
        command = "${pkgs.systemd}/bin/loginctl lock-session";
      }
      {
        timeout = 630;
        command = "${inputs.niri.apps.x86_64-linux.default.program} msg action power-off-monitors";
        resumeCommand = "niri msg action power-on-monitors";
      }
    ];
  };
}
