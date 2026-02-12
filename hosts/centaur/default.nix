# Edit this configuration file to define what should be installed on
# your system. Help is available in the configuration.nix(5) man page, on
# https://search.nixos.org/options and in the NixOS manual (`nixos-help`).

{
  config,
  lib,
  pkgs,
  inputs,
  pkgs-unstable,
  ...
}:
{
  imports = [
    # Include the results of the hardware scan.
    ./hardware-configuration.nix
    ../../modules/hyprland.nix
    ../../modules/nix-ld.nix
    ../../users/carjin/user.nix
    ../../users/lsimek/user.nix
    ./kmonad.nix
  ];

  home-manager = {
    # also pass inputs to home-manager modules
    extraSpecialArgs = {
      inherit inputs pkgs-unstable;
    };
    users = {
      carjin = ../../users/carjin/home.nix;
      lsimek = ../../users/lsimek/home.nix;
    };

    backupFileExtension = "backup";
    useGlobalPkgs = true;
    useUserPackages = true;
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
    host = "localhost";
    loadModels = [
      "deepseek-r1:70b"
      "deepseek-r1:32b-qwen-distill-q8_0"
      "deepseek-r1:14b-qwen-distill-fp16"
      "deepseek-r1:14b"
      # "deepseek-r1:32b"
    ];
    acceleration = "cuda";
  };

  boot.supportedFilesystems = [ "ntfs" ];

  services.open-webui = {
    enable = true;
    openFirewall = true;
    host = "centaur.akita-bleak.ts.net";
    environment = {
      WEBUI_AUTH = "True";
      ENABLE_SIGNUP = "True";
    };
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
  # fonts.packages = with pkgs; [
  #   nerdfonts # bilo bi bolje da su samo iskljcuvo oni koji se koriste
  # ];

  networking.hostName = "centaur"; # Define your hostname.
  networking.networkmanager.enable = true; # Easiest to use and most distros use this by default.

  services.libinput.enable = true;

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

  environment.systemPackages = with pkgs; [
    vim # Do not forget to add an editor to edit configuration.nix! The Nano editor is also installed by default.
    nushell
    xfce.thunar
    picom
    nerd-fonts.jetbrains-mono
    pueue
    ollama-cuda
    heroic
  ];

  programs.vim = {
    enable = true;
    defaultEditor = true;
    #     config = ''
    #       set number relativenumber
    #       set tabstop=2
    #       set expandtab
    #       set shiftwidth=2
    #     '';
  };
  #environment.variables.EDITOR = "vim";

  # programs.mtr.enable = true;
  programs.gnupg.agent = {
    enable = true;
    enableSSHSupport = true;
  };

  services.openssh.enable = true;

  networking.firewall.enable = false;

  system.stateVersion = "23.11";

}
