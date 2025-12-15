{
  programs.mpv = {
    enable = true;
    config = {
      hwdec = "auto-safe";
      profile = "gpu-hq";
      vo = "gpu";
      gpu-context = "wayland";
    };
  };
}
