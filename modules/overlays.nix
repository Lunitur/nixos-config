{ inputs, ... }:
{
  flake.overlays = {
    brother = import ./_overlays/brother.nix;
    colord = (import ./_overlays/colord.nix) inputs.colord;
    # freer-simple = import ./_overlays/freer-simple.nix;
    # lutris = (final: prev: {
    #   lutris = (import inputs.nixpkgs-unstable {
    #     system = prev.stdenv.hostPlatform.system;
    #     config.allowUnfree = true;
    #     config.allowUnfreePredicate = (_: true);
    #   }).lutris;
    # });
    default = final: prev: {
      repl = final.callPackage ./_packages/repl { };
      ammonite = final.callPackage ./_packages/ammonite { };
      wl-ocr = final.callPackage ./_packages/wl-ocr { };
      mfcl3730cdn = final.callPackage ./_packages/mfcl3730cdn { };
      hashcards = final.callPackage ./_packages/hashcards { };
    };
  };
}
