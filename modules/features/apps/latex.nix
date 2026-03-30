{ ... }:
{
  flake.homeModules.latex =
    {
      config,
      lib,
      pkgs,
      ...
    }:
    let
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
            dvipng
            dvisvgm
            wrapfig
            capt-of
            ;
        }
      );
    in
    {
      home.packages = with pkgs; [
        tex
        bibtex-tidy
        texlab
        texmaker
      ];
    };
}
