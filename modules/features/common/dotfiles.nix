{ ... }:
{
  flake.homeModules.common-dotfiles =
    { ... }:
    {
      home.file = {
        # ".config/nushell/completers.nu".source = ../../dotfiles/nushell/completers.nu;
      };
    };
}
