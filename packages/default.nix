{ pkgs, ... }:
{
  repl = pkgs.callPackage ./repl { };
  ammonite = pkgs.callPackage ./ammonite { };
  wl-ocr = pkgs.callPackage ./wl-ocr { };
  hashcards = pkgs.callPackage ./hashcards { };
  chatbox = pkgs.callPackage ./chatbox { };
  nwg-launchers-assets = pkgs.callPackage ./nwg-launchers-assets { };
  mfcl3730cdn = pkgs.callPackage ./mfcl3730cdn { };
}