final: prev: {
  haskell.packages.ghc910.freer-simple =
    prev.haskell.packages.ghc910.freer-simple.overrideAttrs
      (old: {
        src = prev.fetchFromGitHub {
          owner = "georgefst";
          repo = "freer-simple";
          rev = "365bf9294477783b29186cdf48dc608e060a6ec9";
          hash = "";
        };
        meta.broken = false;
      });
}
