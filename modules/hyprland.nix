{ pkgs, ... }:
{

  programs.hyprland.enable = true;
  programs.hyprland.withUWSM = true;
  programs.uwsm.enable = true;

  security.pam.services.hyprlock = { };

  programs.thunar = {
    enable = true;
    plugins = with pkgs.xfce; [
      thunar-archive-plugin
      thunar-volman
    ];
  };

  services.libinput.enable = true;
  services.gvfs.enable = true; # Mount, trash, and other functionalities
  # services.tumbler.enable = true; # Thumbnail support for images
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
    # If you want to use JACK applications, uncomment this
    #jack.enable = true;
  };

  security.polkit.enable = true;
  security.rtkit.enable = true;

  fonts.packages = with pkgs; [
    nerdfonts # bilo bi bolje da su samo iskljcuvo oni koji se koriste
  ];

  xdg.portal.wlr.enable = true;

  #kmonad
  boot.kernelModules = [ "uinput" ];

  services.udev.extraRules = ''
    KERNEL=="uinput", SUBSYSTEM=="misc", TAG+="uaccess", OPTIONS+="static_node=uinput", GROUP="input", MODE="0660"
  '';

  environment.systemPackages = (
    with pkgs;
    [
      # xfce.thunar
      xfce.xfce4-taskmanager
      networkmanagerapplet
      wlr-randr
      grim # screenshot functionality
      slurp # screenshot functionality
      wl-clipboard # wl-copy and wl-paste for copy/paste from stdin / stdout
      mako
      pamixer
      wofi
      dunst
      pavucontrol
      alsa-utils
      brightnessctl
      wlsunset
      telegram-desktop
      vesktop
      signal-desktop
      element-desktop
      kmonad
      yad
      nwg-launchers
      nwg-drawer
      htop
      loupe
      cliphist
      nwg-clipman
      swappy
      waybar
      hyprpaper
      grimblast
      jq
      hyprsunset
      conky
    ]
  );

}
