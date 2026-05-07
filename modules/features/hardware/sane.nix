{ ... }:
{
  flake.nixosModules.sane =
    { pkgs, ... }:
    {
      # Enable SANE to scan documents
      hardware.sane = {
        enable = true;
        extraBackends = [
          pkgs.sane-airscan
          pkgs.brscan4
        ];

        brscan4 = {
          enable = true;
        };
      };
      users.users.carjin = {
        extraGroups = [
          "scanner"
          "lp"
        ];
      };
      environment.systemPackages = with pkgs; [
        simple-scan
      ];
    };
}
