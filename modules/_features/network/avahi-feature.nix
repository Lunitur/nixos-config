{ config, lib, ... }:
let
  cfg = config.features.network.avahi;
in
{
  config = lib.mkIf cfg.enable {
    # network discovery, mDNS
    services.avahi = {
      enable = true;
      nssmdns4 = true;
      publish = {
        enable = true;
        domain = true;
        userServices = true;
      };
    };
  };
}
