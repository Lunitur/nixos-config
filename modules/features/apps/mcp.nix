{ inputs, ... }:
{
  flake.homeModules.mcp-servers =
    {
      config,
      lib,
      pkgs,
      ...
    }:
    {
      home.file.".mcp.json".source = inputs.mcp-servers-nix.lib.mkConfig pkgs {
        flavor = "claude-code";
        programs = {
          nixos.enable = true;
          fetch.enable = true;
          filesystem = {
            enable = true;
            package =
              inputs.mcp-servers-nix.packages.${pkgs.stdenv.hostPlatform.system}.mcp-server-filesystem.overrideAttrs
                (_: {
                  # Avoid lifecycle scripts from unrelated npm workspaces.
                  npmFlags = [ "--ignore-scripts" ];
                });
            args = [
              "${config.home.homeDirectory}/projects"
              "${config.home.homeDirectory}/nixos"
            ];
          };
        };
      };
    };
}
