{ ... }:
{
  flake.nixosModules.waydroid =
    { pkgs, pkgs-unstable, ... }:
    {
      virtualisation.waydroid = {
        enable = true;
        package = pkgs-unstable.waydroid;
      };

      networking.firewall.trustedInterfaces = [ "waydroid0" ];

      boot.kernelParams = [ "psi=1" ];

      environment.systemPackages = with pkgs; [
        android-tools
      ];

      users.users.carjin.extraGroups = [ "adbusers" ];
    };
}
