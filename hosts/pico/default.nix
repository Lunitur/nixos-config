{
  config,
  lib,
  pkgs,
  inputs,
  modules,
  ...
}:
{
  imports = [
    ./hardware-configuration.nix
  ];

  environment.systemPackages = with pkgs; [
    helix
  ];

  services.nginx.virtualHosts.${config.services.nextcloud.hostName} = {
    forceSSL = true;
    sslCertificate = "/etc/private/pico.akita-bleak.ts.net.crt";
    sslCertificateKey = "/etc/private/pico.akita-bleak.ts.net.key";
  };

  services.nextcloud = {
    enable = true;
    package = pkgs.nextcloud30;
    # Instead of using pkgs.nextcloud28Packages.apps,
    # we'll reference the package version specified above
    hostName = "pico.akita-bleak.ts.net";
    https = true;
    config = {
      adminpassFile = "/etc/private/nextcloud-admin-pass";
      adminuser = "root";
    };
    # settings.trusted_domains = [ "pico" ];
    settings = let
      prot = "https"; # or https
      host = "pico.akita-bleak.ts.net";
      dir = "/";
    in {
      overwriteprotocol = prot;
      overwritehost = host;
      overwritewebroot = dir;
      overwrite.cli.url = "${prot}://${host}${dir}/";
      htaccess.RewriteBase = dir;
    };
  };

  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  # boot.kernelPackages = pkgs.linuxPackages_zen;

  networking.hostName = "pico";
  networking.firewall = {
    allowedUDPPorts = [
      80
      443
    ];
    allowedTCPPorts = [
      80
      443
    ];
  };

  system.stateVersion = "24.05";

}
