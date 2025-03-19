{ ... }:
{
  home.file = {

    ".config/nushell/completers.nu".source = ../../dotfiles/nushell/completers.nu;
    ".config/nushell/zoxide.nu".source = ../../dotfiles/nushell/zoxide.nu;
    ".config/kmonad".source = ../../dotfiles/kmonad;
    ".config/dunst".source = ../../dotfiles/dunst;
    # ".config/mako/config".source = ../../dotfiles/mako/config;
    # ".config/sway".source = ../../dotfiles/sway;
    # ".config/swaylock".source = ../../dotfiles/swaylock;
    ".config/waybar".source = ../../dotfiles/waybar;
    ".local/share/nwg-launchers".source = ../../dotfiles/nwg-launchers-assets;
    ".config/nwg-launchers".source = ../../dotfiles/nwg-launchers;
    ".config/hypr/carjin.conf".source = ../../dotfiles/hypr/carjin.conf;
  };

}
