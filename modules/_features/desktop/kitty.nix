{
  config,
  lib,
  ...
}:
let
  cfg = config.features.desktop.kitty;
in
{
  options.features.desktop.kitty.enable = lib.mkEnableOption "Kitty terminal emulator";

  config = lib.mkIf cfg.enable {
    home-manager.users.carjin = {
      programs.kitty = {
        enable = true;
        extraConfig = ''
          copy_on_select clipboard
          enable_audio_bell no
          window_padding_width 5
        '';
      };
    };
  };
}