{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.features.apps.latex;
  tex = (
    pkgs.texlive.combine {
      inherit (pkgs.texlive)
        scheme-medium
        textpos
        etextools
        environ
        fmtcount
        koma-script
        babel
        babel-croatian
        datetime
        geometry
        amsfonts
        csquotes
        tcolorbox
        pgf
        pgfplots
        arydshln
        float
        xcolor
        breqn
        thmtools
        multirow
        hyperref
        booktabs
        listings
        letltxmacro
        adjustbox
        enumitem
        biblatex
        placeins
        mathtools
        autonum
        url
        ;
    }
  );
in
{
  options.features.apps.latex.enable = lib.mkEnableOption "LaTeX";

  config = lib.mkIf cfg.enable {
    home-manager.users.carjin = {
      home.packages = with pkgs; [
        tex
        bibtex-tidy
        texlab
        texmaker
      ];
    };
  };
}