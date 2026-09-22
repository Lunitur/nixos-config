{ ... }:
{
  flake.homeModules.noctalia =
    { pkgs, ... }:
    {
      # `programs.noctalia` is an upstream home-manager option (and `pkgs.noctalia`
      # an upstream nixpkgs package), so no noctalia flake input is needed.

      # Keep the exported Noctalia theme; Stylix otherwise replaces it.
      stylix.targets.noctalia.enable = false;

      programs.noctalia = {
        enable = true;
        package = pkgs.noctalia;
        systemd.enable = true;
        settings = builtins.fromTOML (builtins.readFile ./config.toml);
      };
    };
}
