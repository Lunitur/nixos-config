{
  inputs,
  ...
}:
{
  flake.nixosModules.allFeatures = {
    _class = "nixos";
    imports = [
      ../_features/apps
      ../_features/common
      ../_features/desktop
      ../_features/editors
      ../_features/hardware
      ../_features/network
      ../_features/services
      ../_features/shell
    ];
  };
}
