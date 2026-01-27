{ config, ... }: {
  flake.modules.nixos.desktop-common = {
    imports = [
      config.flake.modules.nixos.pipewire
      config.flake.modules.nixos.polkit
      config.flake.modules.nixos.kmonad
    ];
  };
}
