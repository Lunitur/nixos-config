{ config, pkgs, ... }:

{
  # Enable the OCI container runtime (Podman).
  virtualisation.oci-containers.enable = true;

  # Define the TeamSpeak server container.
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
      "/var/lib/teamspeak-server:/var/tsserver"
    ];
  };

}
