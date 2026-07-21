{ ... }:
{
  perSystem =
    { pkgs, lib, ... }:
    let
      ammonites = pkgs.callPackage ./_packages/ammonite { };
      brother = pkgs.callPackage ./_packages/mfcl3730cdn { };
    in
    {
      packages =
        (lib.filterAttrs (_: lib.isDerivation) (
          {
            repl = pkgs.callPackage ./_packages/repl { };
            wl-ocr = pkgs.callPackage ./_packages/wl-ocr { };
            hashcards = pkgs.callPackage ./_packages/hashcards { };
            ammonite = ammonites.ammonite_3_5;
          }
          // ammonites
          // lib.optionalAttrs pkgs.stdenv.hostPlatform.isx86 {
            mfcl3730cdn-driver = brother.driver;
            mfcl3730cdn-cupswrapper = brother.cupswrapper;
          }
        )) ;

      legacyPackages = pkgs;
    };
}
