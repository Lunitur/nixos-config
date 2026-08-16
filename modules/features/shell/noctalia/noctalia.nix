{ inputs, ... }:
{
  flake.homeModules.noctalia =
    { pkgs, ... }:
    {
      imports = [ inputs.noctalia.homeModules.default ];

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
