{
  programs.foot = {
    enable = true;
    server.enable = true;
    settings = {
      key-bindings = {
        scrollback-up-half-page = "Control+k";
        scrollback-down-half-page = "Control+j";
        scrollback-up-line = "Control+Shift+k";
        scrollback-down-line = "Control+Shift+j";
      };
      colors = {
        # alpha = lib.mkForce 1;
        # background = "#E8E8E8";
      };
    };
  };
}
