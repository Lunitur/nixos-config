{
  programs.foot = {
    enable = true;
    server.enable = true;
    settings = {
      key-bindings = {
        scrollback-up-half-page = "Control+Shift+k";
        scrollback-down-half-page = "Control+Shift+j";
        scrollback-up-line = "Control+k";
        scrollback-down-line = "Control+j";
      };
      colors = {
        # alpha = lib.mkForce 1;
        # background = "#E8E8E8";
      };
    };
  };
}
