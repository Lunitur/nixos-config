{
  config,
  lib,
  ...
}:
let
  cfg = config.features.shell.jujutsu;
in
{
  options.features.shell.jujutsu.enable = lib.mkEnableOption "Jujutsu version control";

  config = lib.mkIf cfg.enable {
    home-manager.users.carjin = {
      programs.jujutsu = {
        enable = true;
        settings = {
          user = {
            email = "karlo.puselj@gmail.com";
            name = "Lunitur";
          };
        };
      };
    };
  };
}