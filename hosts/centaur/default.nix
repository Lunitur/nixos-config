# Edit this configuration file to define what should be installed on
# your system. Help is available in the configuration.nix(5) man page, on
# https://search.nixos.org/options and in the NixOS manual (`nixos-help`).

{
  config,
  lib,
  pkgs,
  modules,
  pkgs-unstable,
  ...
}:
{
  imports = [
    # Include the results of the hardware scan.
    ./hardware-configuration.nix
    modules.hyprland
    modules.nix-ld
    ../../users/carjin/user.nix
    ../../users/lsimek/user.nix
  ];

  home-manager = {
    # also pass inputs to home-manager modules
    extraSpecialArgs = {
      inherit modules pkgs-unstable;
    };
    users = {
      carjin = import ../../users/carjin/home.nix;
      lsimek = import ../../users/lsimek/home.nix;
    };

    backupFileExtension = "backup";
  };

  services.xserver.enable = true;

  services.displayManager.sddm = {
    enable = true;
    wayland.enable = true;
    settings = {
      Autologin = {
        Session = "hyprland-uwsm.desktop";
        User = "lsimek";
      };
    };
  };

  services._3proxy = {
    enable = true;
    services = [
      {
        type = "socks";
        auth = [ "strong" ];
        acl = [
          {
            rule = "allow";
            users = [ "master" ];
          }
        ];
      }
    ];
    usersFile = "/etc/3proxy.passwd";
  };

  environment.etc = {
    "3proxy.passwd".text = ''
      master:CR:$1$czCls9cH$.zIWiB42e4huFnrGAbwos.
    '';
  };

  networking.firewall.allowedUDPPorts = [ 1080 ];
  networking.firewall.allowedTCPPorts = [ 1080 ];

  services.ollama = {
    enable = true;
    openFirewall = true;
    host = "centaur.akita-bleak.ts.net";
    loadModels = [
      "qwen2.5-coder:32b"
      "llama3.1:8b"
    ];
    acceleration = "cuda";
  };

  nix.settings.experimental-features = [ "nix-command" ];

  # Use the systemd-boot EFI boot loader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  #boot.loader = {
  #  efi = {
  #    canTouchEfiVariables = true;
  #    efiSysMountPoint = "/boot/efi";
  #  };
  #  grub = {
  #      efiSupport = true;
  #      device = "nodev";
  #  };
  #};

  # Enable OpenGL
  hardware.graphics.enable = true;

  # Load nvidia driver for Xorg and Wayland
  services.xserver.videoDrivers = [ "nvidia" ];

  hardware.nvidia = {

    forceFullCompositionPipeline = true;

    # Modesetting is required.
    modesetting.enable = true;

    # Nvidia power management. Experimental, and can cause sleep/suspend to fail.
    # Enable this if you have graphical corruption issues or application crashes after waking
    # up from sleep. This fixes it by saving the entire VRAM memory to /tmp/ instead
    # of just the bare essentials.
    powerManagement.enable = false;

    # Fine-grained power management. Turns off GPU when not in use.
    # Experimental and only works on modern Nvidia GPUs (Turing or newer).
    powerManagement.finegrained = false;

    # Use the NVidia open source kernel module (not to be confused with the
    # independent third-party "nouveau" open source driver).
    # Support is limited to the Turing and later architectures. Full list of
    # supported GPUs is at:
    # https://github.com/NVIDIA/open-gpu-kernel-modules#compatible-gpus
    # Only available from driver 515.43.04+
    # Currently alpha-quality/buggy, so false is currently the recommended setting.
    open = false;

    # Enable the Nvidia settings menu,
    # accessible via `nvidia-settings`.
    nvidiaSettings = true;

    # Optionally, you may need to select the appropriate driver version for your specific GPU.
    package = config.boot.kernelPackages.nvidiaPackages.beta;

  };

  # Unfree software
  nixpkgs.config.allowUnfree = true;

  users.defaultUserShell = pkgs.nushell;
  fonts.packages = with pkgs; [
    nerdfonts # bilo bi bolje da su samo iskljcuvo oni koji se koriste
  ];

  networking.hostName = "centaur"; # Define your hostname.
  # Pick only one of the below networking options.
  # networking.wireless.enable = true;  # Enables wireless support via wpa_supplicant.
  networking.networkmanager.enable = true; # Easiest to use and most distros use this by default.

  # Set your time zone.
  # time.timeZone = "Europe/Amsterdam";

  # Configure network proxy if necessary
  # networking.proxy.default = "http://user:password@proxy:port/";
  # networking.proxy.noProxy = "127.0.0.1,localhost,internal.domain";

  # Select internationalisation properties.
  # i18n.defaultLocale = "en_US.UTF-8";
  # console = {
  #   font = "Lat2-Terminus16";
  #   keyMap = "us";
  #   useXkbConfig = true; # use xkb.options in tty.
  # };

  # Configure keymap in X11
  # services.xserver.xkb.layout = "us";
  # services.xserver.xkb.options = "eurosign:e,caps:escape";

  # Enable CUPS to print documents.
  # services.printing.enable = true;

  # Enable touchpad support (enabled default in most desktopManager).
  services.libinput.enable = true;

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users.lsimek = {
    isNormalUser = true;
    extraGroups = [ "wheel" ]; # Enable ‘sudo’ for the user.
    packages = with pkgs; [
      firefox
      tree
      git
      fish
      feh
    ];
  };

  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages = with pkgs; [
    vim # Do not forget to add an editor to edit configuration.nix! The Nano editor is also installed by default.
    nushell
    xfce.thunar
    python311Packages.qtile
    picom
    nerdfonts
    pueue
    ollama-cuda
  ];

  programs.vim = {
    defaultEditor = true;
    #     config = ''
    #       set number relativenumber
    #       set tabstop=2
    #       set expandtab
    #       set shiftwidth=2
    #     '';
  };
  #environment.variables.EDITOR = "vim";

  # Some programs need SUID wrappers, can be configured further or are
  # started in user sessions.
  # programs.mtr.enable = true;
  programs.gnupg.agent = {
    enable = true;
    enableSSHSupport = true;
  };

  # List services that you want to enable:

  # Enable the OpenSSH daemon.
  services.openssh.enable = true;

  # Open ports in the firewall.
  # networking.firewall.allowedTCPPorts = [ ... ];
  # networking.firewall.allowedUDPPorts = [ ... ];
  # Or disable the firewall altogether.
  networking.firewall.enable = false;

  # Copy the NixOS configuration file and link it from the resulting system
  # (/run/current-system/configuration.nix). This is useful in case you
  # accidentally delete configuration.nix.
  # system.copySystemConfiguration = true;

  # This option defines the first version of NixOS you have installed on this particular machine,
  # and is used to maintain compatibility with application data (e.g. databases) created on older NixOS versions.
  #
  # Most users should NEVER change this value after the initial install, for any reason,
  # even if you've upgraded your system to a new NixOS release.
  #
  # This value does NOT affect the Nixpkgs version your packages and OS are pulled from,
  # so changing it will NOT upgrade your system.
  #
  # This value being lower than the current NixOS release does NOT mean your system is
  # out of date, out of support, or vulnerable.
  #
  # Do NOT change this value unless you have manually inspected all the changes it would make to your configuration,
  # and migrated your data accordingly.
  #
  # For more information, see `man configuration.nix` or https://nixos.org/manual/nixos/stable/options#opt-system.stateVersion .
  system.stateVersion = "23.11"; # Did you read the comment?

}
