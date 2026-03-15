{
  config,
  lib,
  ...
}:
let
  cfg = config.features.hardware.audio;
in
{
  options.features.hardware.audio.enable = lib.mkEnableOption "Audio (Pipewire)";

  config = lib.mkIf cfg.enable {
    services.pipewire = {
      enable = true;
      alsa.enable = true;
      alsa.support32Bit = true;
      pulse.enable = true;
      # If you want to use JACK applications, uncomment this
      #jack.enable = true;
    };

    security.rtkit.enable = true;
  };
}