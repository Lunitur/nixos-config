{
  programs.niri.settings = {
    prefer-no-csd = true;
    window-rules = [
      {
        geometry-corner-radius = {
          bottom-left = 12.0;
          bottom-right = 12.0;
          top-left = 12.0;
          top-right = 12.0;
        };
        clip-to-geometry = true;
        # prefer-no-csd = true;
      }
      #   {
      #     match = "app-id=(mpv)|(imv)|(showmethekey-gtk)";
      #     default-floating = true;
      #   }
      #   {
      #     match = "app-id=showmethekey-gtk";
      #     border.width = 0;
      #   }
    ];
  };
}
