{
  programs.niri.settings = {
    prefer-no-csd = true;
    window-rules = [
      {
        # geometry-corner-radius = 12;
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
