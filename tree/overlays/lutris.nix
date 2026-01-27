{ inputs, ... }: {
  flake.overlays.lutris = final: prev: {
    lutris = inputs.nixpkgs-unstable.legacyPackages.${prev.system}.lutris;
  };
}
