{ pkgs, ... }:
{
  repl = pkgs.callPackage ./repl { };

  ammonite = pkgs.callPackage ./ammonite { };

  wl-ocr = pkgs.callPackage ./wl-ocr { };

  mfcl3770cdw = pkgs.callPackage ./mfcl3770cdw { };

  hashcards = pkgs.callPackage ./hashcards { };
}
