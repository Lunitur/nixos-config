{ inputs, ... }:
{
  flake.overlays = {
    brother = final: prev: {
      mfcl3730cdnlpr = (prev.callPackage ./_packages/mfcl3730cdn { }).driver;
      mfcl3730cdncupswrapper = (prev.callPackage ./_packages/mfcl3730cdn { }).cupswrapper;
    };
    inputs =
      final: prev:
      let
        system = prev.stdenv.hostPlatform.system;
        selfPkgs = inputs.self.packages.${system} or { };
      in
      {
        inputs = {
          self = selfPkgs;
        };
      }
      // selfPkgs;
    default = final: prev: {
      repl = final.callPackage ./_packages/repl { };
      ammonite = final.callPackage ./_packages/ammonite { };
      wl-ocr = final.callPackage ./_packages/wl-ocr { };
      hashcards = final.callPackage ./_packages/hashcards { };
    };
  };
}
