{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.features.shell.zsh;
in
{
  options.features.shell.zsh.enable = lib.mkEnableOption "Zsh shell";

  config = lib.mkIf cfg.enable {
    programs.zsh.enable = true;
    home-manager.users.carjin = {
      imports = [ ./zsh.nix ];
    };
  };
}
