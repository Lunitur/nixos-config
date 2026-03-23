{ self, inputs, ... }:
{
  perSystem =
    { pkgs, ... }:
    {
      packages.noctalia = inputs.wrapper-modules.wrappers.noctalia-shell.wrap {
        inherit pkgs;
        package = inputs.noctalia.packages.${pkgs.stdenv.hostPlatform.system}.default;
        settings = (builtins.fromJSON (builtins.readFile ./noctalia.json));
      };
    };
}
