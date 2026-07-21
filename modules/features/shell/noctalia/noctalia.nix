{ inputs, ... }:
{
  flake.homeModules.noctalia =
    { ... }:
    {
      imports = [ inputs.noctalia.homeModules.default ];

      # Keep the exported Noctalia theme; Stylix otherwise replaces it.
      stylix.targets.noctalia.enable = false;

      programs.noctalia = {
        enable = true;
        systemd.enable = true;
        settings = builtins.fromTOML (builtins.readFile ./config.toml);
      };
    };
}
