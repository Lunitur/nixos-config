{ pkgs, ... }:
{
  xdg.mimeApps = {
    enable = true;

    defaultApplications = {
      # --- Web & URLs ---
      "text/html" = [ "firefox.desktop" ];
      "x-scheme-handler/http" = [ "firefox.desktop" ];
      "x-scheme-handler/https" = [ "firefox.desktop" ];
      "x-scheme-handler/about" = [ "firefox.desktop" ];
      "x-scheme-handler/unknown" = [ "firefox.desktop" ];
      "x-scheme-handler/chrome" = [ "firefox.desktop" ];

      # --- Documents ---
      "application/pdf" = [ "org.pwmt.zathura.desktop" ]; # or org.gnome.Evince.desktop
      "application/epub+zip" = [ "org.pwmt.zathura.desktop" ];

      # Office (LibreOffice examples)
      "application/vnd.oasis.opendocument.text" = [ "writer.desktop" ];
      "application/vnd.oasis.opendocument.spreadsheet" = [ "calc.desktop" ];
      "application/vnd.oasis.opendocument.presentation" = [ "impress.desktop" ];
      "application/vnd.openxmlformats-officedocument.wordprocessingml.document" = [ "writer.desktop" ]; # .docx
      "application/vnd.openxmlformats-officedocument.spreadsheetml.sheet" = [ "calc.desktop" ]; # .xlsx
      "application/vnd.openxmlformats-officedocument.presentationml.presentation" = [
        "org.pwmt.zathura.desktop"
      ]; # .pptx

      # --- Images ---
      "image/jpeg" = [ "org.gnome.Loupe.desktop" ];
      "image/png" = [ "org.gnome.Loupe.desktop" ];
      "image/gif" = [ "org.gnome.Loupe.desktop" ];
      "image/webp" = [ "org.gnome.Loupe.desktop" ];
      "image/tiff" = [ "org.gnome.Loupe.desktop" ];
      "image/bmp" = [ "org.gnome.Loupe.desktop" ];
      "image/svg+xml" = [ "org.gnome.Loupe.desktop" ];
      # Editor fallback (optional, use associations.added for "Open With" instead)
      # "image/x-xcf" = [ "gimp.desktop" ];

      # --- Audio & Video ---
      "video/mp4" = [ "mpv.desktop" ];
      "video/x-matroska" = [ "mpv.desktop" ]; # .mkv
      "video/webm" = [ "mpv.desktop" ];
      "video/quicktime" = [ "mpv.desktop" ];
      "video/x-flv" = [ "mpv.desktop" ];
      "audio/mpeg" = [ "mpv.desktop" ]; # .mp3
      "audio/x-wav" = [ "mpv.desktop" ];
      "audio/mp4" = [ "mpv.desktop" ];
      "audio/flac" = [ "mpv.desktop" ];

      # --- Development & Text ---
      "text/plain" = [ "Helix.desktop" ];
      "text/markdown" = [ "Helix.desktop" ];
      "application/x-shellscript" = [ "Helix.desktop" ];
      "application/json" = [ "Helix.desktop" ];
      "application/xml" = [ "Helix.desktop" ];
      "application/yaml" = [ "Helix.desktop" ];
      "text/css" = [ "Helix.desktop" ];
      "text/x-python" = [ "Helix.desktop" ];
      "text/x-go" = [ "Helix.desktop" ];
      # Nix files
      "text/x-nix" = [ "Helix.desktop" ];

      # --- Archives ---
      "application/zip" = [ "peazip.desktop" ];
      "application/x-tar" = [ "peazip.desktop" ];
      "application/x-bzip2" = [ "peazip.desktop" ];
      "application/x-gzip" = [ "peazip.desktop" ];
      "application/x-xz" = [ "peazip.desktop" ];
      "application/x-7z-compressed" = [ "peazip.desktop" ];
      "application/x-rar" = [ "peazip.desktop" ];

      # --- Directories (File Manager) ---
      "inode/directory" = [ "yazi.desktop" ]; # or org.gnome.Nautilus.desktop, thunar.desktop
    };
  };

}
