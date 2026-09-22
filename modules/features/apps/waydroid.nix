{ ... }:
{
  flake.nixosModules.waydroid =
    { pkgs, ... }:
    {
      virtualisation.waydroid = {
        enable = true;
        package = pkgs.waydroid;
      };

      networking.firewall.trustedInterfaces = [ "waydroid0" ];

      boot.kernelParams = [ "psi=1" ];

      environment.systemPackages = with pkgs; [
        android-tools
      ];

      users.users.carjin.extraGroups = [ "adbusers" ];
    };
}
