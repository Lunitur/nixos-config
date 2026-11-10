{ ... }:
{
  flake.nixosModules.cerberus =
    { pkgs, ... }:
    let
      ucm = pkgs.alsa-ucm-conf.overrideAttrs (old: {
        # The AMD machine driver can omit the RT721 headphone pin switch.
        patches = (old.patches or [ ]) ++ [ ./_audio/rt721-headphones.patch ];
        postPatch = (old.postPatch or "") + ''
          cp ${./_audio/tas2783.conf} ucm2/sof-soundwire/tas2783.conf
        '';
      });
      ucmPath = "${ucm}/share/alsa/ucm2";
    in
    {
      # The PX13's ACP70 SoundWire quirk is missing from the default 6.18 kernel.
      boot.kernelPackages = pkgs.linuxPackages_latest;

      systemd.user.services.pipewire.environment.ALSA_CONFIG_UCM2 = ucmPath;
      systemd.user.services.wireplumber.environment.ALSA_CONFIG_UCM2 = ucmPath;
      environment.sessionVariables.ALSA_CONFIG_UCM2 = ucmPath;
      environment.systemPackages = [ pkgs.alsa-utils ];
    };
}
