{ ... }: {
  flake.overlays.my-packages = final: prev: {
    repl = prev.callPackage ../../packages/repl { };
    ammonite = prev.callPackage ../../packages/ammonite { }; 
    wl-ocr = prev.callPackage ../../packages/wl-ocr { };
    hashcards = prev.callPackage ../../packages/hashcards { };
    chatbox = prev.callPackage ../../packages/chatbox { };
    nwg-launchers-assets = prev.callPackage ../../packages/nwg-launchers-assets { };
    mfcl3730cdn = prev.callPackage ../../packages/mfcl3730cdn { };
  };
}