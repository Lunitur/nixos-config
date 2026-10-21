{ inputs, ... }:
{
  flake.nixosModules.vayu =
    {
      config,
      lib,
      options,
      pkgs,
      ...
    }:
    {
      imports = [ inputs.self.nixosModules.user-carjin ];

      users.users.root.openssh.authorizedKeys.keys =
        config.users.users.carjin.openssh.authorizedKeys.keys;

      networking.hostName = "vayu";
      networking.firewall = {
        trustedInterfaces = [ "wt0" ];
        checkReversePath = "loose";
      };

      services = lib.setAttrByPath (
        if options.services ? desktopManager.phosh then
          [
            "desktopManager"
            "phosh"
          ]
        else
          [
            "xserver"
            "desktopManager"
            "phosh"
          ]
      ) {
        user = "carjin";
        group = "users";
      };

      environment.systemPackages = with pkgs; [
        btrfs-progs
        firefox
        gnome-console
        nautilus
        epiphany
        gnome-text-editor
        loupe
        papers
        gnome-calculator
        gnome-clocks
        gnome-weather
        gnome-calendar
      ];

      system.stateVersion = "26.05";
    };
}
