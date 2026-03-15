{ lib, config, ... }:

let
  cfg = config.features.shell.ls-colors;

  hexDigitToInt =
    c:
    let
      hexChars = "0123456789abcdef";
    in
    lib.stringLength (lib.head (lib.splitString c (lib.toLower hexChars)));

  hexToRgb =
    hexColor:
    let
      r = lib.substring 0 2 hexColor;
      g = lib.substring 2 2 hexColor;
      b = lib.substring 4 2 hexColor;
      toDecimal = hex: hexDigitToInt (lib.substring 0 1 hex) * 16 + hexDigitToInt (lib.substring 1 1 hex);
    in
    "${toString (toDecimal r)};${toString (toDecimal g)};${toString (toDecimal b)}";

  generateLsColors =
    colors:
    let
      mkColor = color: "38;2;${hexToRgb color}";
      colorMap = {
        di = mkColor colors.base0D;
        fi = mkColor colors.base05;
        ln = mkColor colors.base0C;
        ex = mkColor colors.base0A;
        bd = mkColor colors.base0E;
        cd = mkColor colors.base0E;
        so = mkColor colors.base0E;
        pi = mkColor colors.base0E;
        or = mkColor colors.base08;
        mi = mkColor colors.base08;
        su = mkColor colors.base0B;
        sg = mkColor colors.base0B;
        ca = mkColor colors.base0B;
        tw = mkColor colors.base0A;
        ow = mkColor colors.base0A;
        st = mkColor colors.base0E;
        ee = mkColor colors.base05;
        no = mkColor colors.base05;
        rs = mkColor colors.base05;
        mh = mkColor colors.base05;
        lc = mkColor colors.base05;
        rc = mkColor colors.base05;
        ec = mkColor colors.base05;
      };
    in
    lib.concatStringsSep ":" (lib.mapAttrsToList (k: v: "${k}=${v}") colorMap);

in
{
  options.features.shell.ls-colors = {
    enable = lib.mkEnableOption "LS_COLORS";
  };

  config = lib.mkIf cfg.enable {
    home-manager.users.carjin = {
      programs.nushell.environmentVariables = {
        LS_COLORS = lib.mkIf config.stylix.enable (lib.mkDefault ''${generateLsColors config.lib.stylix.colors}'');
      };
    };
  };
}