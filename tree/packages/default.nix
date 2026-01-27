{ ... }: {
  perSystem = { pkgs, ... }: {
    packages = let
      ammonite-pkgs = pkgs.callPackage ../../packages/ammonite { };
      mfcl3730cdn-pkgs = pkgs.callPackage ../../packages/mfcl3730cdn { };
    in {
      repl = pkgs.callPackage ../../packages/repl { };
      
      inherit (ammonite-pkgs) ammonite_2_12 ammonite_2_13 ammonite_3_3 ammonite_3_5;
      ammonite = ammonite-pkgs.ammonite_3_5;

      wl-ocr = pkgs.callPackage ../../packages/wl-ocr { };
      hashcards = pkgs.callPackage ../../packages/hashcards { };
      chatbox = pkgs.callPackage ../../packages/chatbox { };
      nwg-launchers-assets = pkgs.callPackage ../../packages/nwg-launchers-assets { };
      
      inherit (mfcl3730cdn-pkgs) driver cupswrapper;
    };
  };
}
