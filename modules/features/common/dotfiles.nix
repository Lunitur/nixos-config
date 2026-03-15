{
  config,
  lib,
  ...
}:
let
  cfg = config.features.common.dotfiles;
in
{
  options.features.common.dotfiles.enable = lib.mkEnableOption "User dotfiles";

  config = lib.mkIf cfg.enable {
    home-manager.users.carjin = {
      home.file = {
        # ".config/nushell/completers.nu".source = ../../dotfiles/nushell/completers.nu;
      };
    };
  };
}