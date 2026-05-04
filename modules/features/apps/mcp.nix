{ inputs, ... }: {
  flake.homeModules.mcp-servers = { config, lib, pkgs, ... }: {
    home.file.".mcp.json".source = inputs.mcp-servers-nix.lib.mkConfig pkgs {
      flavor = "claude-code";
      programs = {
        nixos.enable = true;
        filesystem = {
          enable = true;
          args = [ 
            "${config.home.homeDirectory}/projects"
            "${config.home.homeDirectory}/nixos"
          ];
        };
      };
    };
  };
}