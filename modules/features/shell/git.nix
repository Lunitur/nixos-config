{
  config,
  lib,
  ...
}:
let
  cfg = config.features.shell.git;
in
{
  options.features.shell.git.enable = lib.mkEnableOption "Git";

  config = lib.mkIf cfg.enable {
    home-manager.users.carjin = {
      programs.git = {
        enable = true;
        settings = {
          user = {
            email = "karlo.puselj@gmail.com";
            name = "Lunitur";
          };
          receive.denyCurrentBranch = "warn";
          pull.rebase = true;
          core.editor = "hx";
        };
      };
    };
  };
}