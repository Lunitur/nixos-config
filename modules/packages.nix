{ inputs, ... }:
{
  perSystem =
    {
      pkgs,
      lib,
      system,
      ...
    }:
    let
      ammonites = pkgs.callPackage ./_packages/ammonite { };
      brother = pkgs.callPackage ./_packages/mfcl3730cdn { };
      allPackages = {
        repl = pkgs.callPackage ./_packages/repl { };
        wl-ocr = pkgs.callPackage ./_packages/wl-ocr { };
        hashcards = pkgs.callPackage ./_packages/hashcards { };
        ammonite = ammonites.ammonite_3_5;
      }
      // (
        if pkgs.stdenv.hostPlatform.isx86 then
          {
            mfcl3730cdn-driver = brother.driver;
            mfcl3730cdn-cupswrapper = brother.cupswrapper;
          }
        else
          { }
      )
      // ammonites;
    in
    {
      packages = lib.filterAttrs (_: lib.isDerivation) allPackages;
    };
}
