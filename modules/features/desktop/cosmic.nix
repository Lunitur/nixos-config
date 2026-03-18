{ ... }:
{
  flake.nixosModules.cosmic =
    {
      config,
      lib,
      pkgs,
      inputs,
      ...
    }:
    {
      nix.settings = {
        substituters = [ "https://cosmic.cachix.org/" ];
        trusted-public-keys = [ "cosmic.cachix.org-1:Dya9IyXD4xdBehWjrkPv6rtxpmMdRel02smYzA85dPE=" ];
      };
      services.displayManager.cosmic-greeter.enable = true;
      services.desktopManager.cosmic.enable = true;
    };
}
