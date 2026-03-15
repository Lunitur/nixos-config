{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.features.services.teamspeak;
in
{
  options.features.services.teamspeak.enable = lib.mkEnableOption "TeamSpeak server";

  config = lib.mkIf cfg.enable {
    virtualisation.oci-containers.containers.teamspeak-server = {
      # The actual systemd service will be named `container-teamspeak-server.service`.

      image = "teamspeaksystems/teamspeak6-server:latest";

      autoStart = true;

      ports = [
        "9987:9987/udp" # Voice Port
        "30033:30033/tcp" # File Transfer
      ];

      environment = {
        TSSERVER_LICENSE_ACCEPTED = "accept";
      };

      # Equivalent to `volumes`. This maps a directory on your NixOS host
      # to a directory inside the container for persistent data.
      volumes = [
        "teamspeak-data:/var/tsserver"
      ];
    };
  };
}