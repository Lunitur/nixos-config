{
  config,
  lib,
  pkgs,
  inputs,
  ...
}:
{
  imports = [
    ./stylix
  ];

  users.users.carjin = {
    isNormalUser = true;
    extraGroups = [
      "wheel"
      "networkmanager"
      "input"
      "libvirtd"
      "wireshark"
      "kvm"
    ]; # 'input' for kmonad
    openssh.authorizedKeys.keys = [
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIDhjgro/JnCCqYuHT/eiTv0EYqW8kN/MYL/nBmOJ+5l9 karlo.puselj@gmail.com"
      # "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIAa4p4eaMH3uBaxjn+yQuD7TzvDzE/5gP3/Xshn1S0vj tinjano@proton.me"
    ];
  };

  # Nextcloud-client autologin
  services.gnome.gnome-keyring.enable = true;
  security.pam.services.carjin.enableGnomeKeyring = true;

}
