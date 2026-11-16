{ inputs, ... }:
{
  flake.nixosModules.nix-unfree =
    { pkgs, ... }:
    let
      source = inputs.nixpkgs;
      nixpkgsUnfree =
        pkgs.runCommand "source"
          {
            defaultNix = ''
              { config ? { }, ... }@args:
              import ${source} (args // {
                config = config // { allowUnfree = true; };
              })
            '';
            flakeNix = ''
              {
                outputs = _: let
                  nixpkgs = builtins.getFlake "path:${source}?narHash=${source.narHash}";
                in nixpkgs.outputs // {
                  legacyPackages = nixpkgs.lib.genAttrs nixpkgs.lib.systems.flakeExposed (
                    system: import nixpkgs { inherit system; config.allowUnfree = true; }
                  );
                };
              }
            '';
            passAsFile = [
              "defaultNix"
              "flakeNix"
            ];
          }
          ''
            mkdir -p "$out"
            cp "$defaultNixPath" "$out/default.nix"
            cp "$flakeNixPath" "$out/flake.nix"
          '';
    in
    {
      # Pure flake evaluation cannot read NIXPKGS_ALLOW_UNFREE or user config.
      nix.registry.nixpkgs.to = {
        type = "path";
        path = toString nixpkgsUnfree;
      };
    };
}
