{
  programs.niri.settings = {
    outputs = {
      "eDP-1" = {
        # To improve color quality/saturation, you can load an ICC profile:
        # icc-profile = "${../../../hosts/victus/color-profile-1.icm}";
        mode = {
          width = 1920;
          height = 1080;
          refresh = 144.005005;
        };
        position = {
          x = 0;
          y = 0;
        };
        scale = 1.0;
      };
      "DP-1" = {
        mode = {
          width = 1920;
          height = 1080;
          refresh = 143.854996;
        };
        position = {
          x = 0;
          y = -1080;
        };
        scale = 1.0;
      };
      "DP-2" = {
        mode = {
          width = 1920;
          height = 1080;
          refresh = 143.854996;
        };
        position = {
          x = 0;
          y = -1080;
        };
        scale = 1.0;
      };
      "DSI-1" = {
        mode = {
          width = 1200;
          height = 1920;
          refresh = 50.00200;
        };
        position = {
          x = 0;
          y = 0;
        };
        scale = 1.0;
        transform.rotation = 270;
      };
      # {
      #   name = "DSI-1";
      #   mode = {
      #     width = 1920;
      #     height = 1080;
      #     refresh = 143.854996;
      #   };
      #   position = {
      #     x = 0;
      #     y = 0;
      #   };
      #   scale = 1.0;
      # };
      "HDMI-A-1" = {
        name = "HDMI-A-1";
        enable = false;
      };
    };
  };
}
