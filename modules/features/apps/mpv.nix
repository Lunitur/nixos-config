{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.features.apps.mpv;
in
{
  options.features.apps.mpv.enable = lib.mkEnableOption "MPV player";

  config = lib.mkIf cfg.enable {
    home-manager.users.carjin = {
      programs.mpv = {
        enable = true;
        config = {
          hwdec = "auto-safe";
          profile = "gpu-hq";
          vo = "gpu";
          gpu-context = "wayland";
        };
      };
    };
  };
}