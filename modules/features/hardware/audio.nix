{ ... }:
{
  flake.nixosModules.hardware-audio =
    { config, lib, ... }:
    {
      services.pipewire = {
        enable = true;
        alsa.enable = true;
        alsa.support32Bit = true;
        pulse.enable = true;
      };
      security.rtkit.enable = true;
    };
}
