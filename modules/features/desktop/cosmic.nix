{
  config,
  lib,
  pkgs,
  inputs,
  ...
}:
let
  cfg = config.features.desktop.cosmic;
  nixos-cosmic = inputs.nixos-cosmic or { nixosModules.default = { }; };
in
{
  options.features.desktop.cosmic.enable = lib.mkEnableOption "COSMIC desktop";

  config = lib.mkIf cfg.enable {
    # imports = [ nixos-cosmic.nixosModules.default ]; # cannot be inside mkIf easily if it defines options

    nix.settings = {
      substituters = [ "https://cosmic.cachix.org/" ];
      trusted-public-keys = [ "cosmic.cachix.org-1:Dya9IyXD4xdBehWjrkPv6rtxpmMdRel02smYzA85dPE=" ];
    };

    services.displayManager.cosmic-greeter.enable = true;
    services.desktopManager.cosmic.enable = true;
  };
}