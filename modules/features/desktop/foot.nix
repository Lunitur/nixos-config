{
  config,
  lib,
  ...
}:
let
  cfg = config.features.desktop.foot;
in
{
  options.features.desktop.foot.enable = lib.mkEnableOption "Foot terminal emulator";

  config = lib.mkIf cfg.enable {
    home-manager.users.carjin = {
      programs.foot = {
        enable = true;
        server.enable = true;
        settings = {
          key-bindings = {
            scrollback-up-half-page = "Control+k";
            scrollback-down-half-page = "Control+j";
            scrollback-up-line = "Control+Shift+k";
            scrollback-down-line = "Control+Shift+j";
          };
        };
      };
    };
  };
}