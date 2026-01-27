{ ... }: {
  flake.modules.nixos.network.avahi = {
    services.avahi = {
      enable = true;
      nssmdns4 = true;
      publish = { enable = true; domain = true; userServices = true; };
    };
  };
}
