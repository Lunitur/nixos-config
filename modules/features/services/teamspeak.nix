{ ... }:
{
  flake.nixosModules.teamspeak-server =
    { config, lib, ... }:
    {
      virtualisation.oci-containers.containers.teamspeak-server = {
        image = "teamspeaksystems/teamspeak6-server:latest";
        autoStart = true;
        ports = [
          "9987:9987/udp"
          "30033:30033/tcp"
        ];
        environment = {
          TSSERVER_LICENSE_ACCEPTED = "accept";
        };
        volumes = [ "teamspeak-data:/var/tsserver" ];
      };
    };
}
