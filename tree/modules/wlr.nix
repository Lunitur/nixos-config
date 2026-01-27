{ ... }: {
  flake.modules.nixos.wlr = {
    xdg.portal.wlr.enable = true;
  };
}
