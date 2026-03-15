{
  config,
  lib,
  ...
}:
let
  cfg = config.features.desktop.fuzzel;
in
{
  options.features.desktop.fuzzel.enable = lib.mkEnableOption "Fuzzel application launcher";

  config = lib.mkIf cfg.enable {
    home-manager.users.carjin = {
      programs.fuzzel.enable = true;
      programs.fuzzel.settings = {
        main = {
          prompt = "> ";
          lines = 15;
          width = 40;
          icons-enabled = "yes";
        };
        border = {
          width = 1;
          radius = 5;
        };
      };
    };
  };
}