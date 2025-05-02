{ pkgs, ... }:
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
        # inputenc
        babel
        babel-croatian
        datetime
        geometry
        amsfonts
        # amsmath
        # amssymb
        # amsthm
        csquotes
        tcolorbox
        pgf
        pgfplots
        arydshln
        float
        xcolor
        # fontenc
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
        # mathrsfs
        placeins
        mathtools
        autonum
        # bm
        url # dvisvgm
        # dvipng # for preview and export as html
        # wrapfig
        # amsmath
        # ulem
        # hyperref
        # capt-of
        ;
      #(setq org-latex-compiler "lualatex")
      #(setq org-preview-latex-default-process 'dvisvgm)
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
}
