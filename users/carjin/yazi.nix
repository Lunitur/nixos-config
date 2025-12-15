{ pkgs, ... }:
{
  programs.yazi = {
    enable = true;
    enableNushellIntegration = true;
    plugins = with pkgs.yaziPlugins; {
      inherit
        nord
        yatline
        git
        # sudo
        ouch
        # rsync
        # restore
        compress
        jump-to-char
        ;
    };
    flavors = { inherit (pkgs.yaziPlugins) nord; };
    theme = {
      flavor = {
        dark = "nord";
        light = "nord";
      };
    };

    keymap = {
      mgr.prepend_keymap = [
        # jump-to-char
        {
          on = "f";
          run = "plugin jump-to-char";
          desc = "Jump to char";
        }
        # compress
        {
          on = [
            "c"
            "a"
            "a"
          ];
          run = "plugin compress";
          desc = "Archive selected files";
        }
        {
          on = [
            "c"
            "a"
            "p"
          ];
          run = "plugin compress -p";
          desc = "Archive selected files (password)";
        }
        {
          on = [
            "c"
            "a"
            "h"
          ];
          run = "plugin compress -ph";
          desc = "Archive selected files (password+header)";
        }
        {
          on = [
            "c"
            "a"
            "l"
          ];
          run = "plugin compress -l";
          desc = "Archive selected files (compression level)";
        }
        {
          on = [
            "c"
            "a"
            "u"
          ];
          run = "plugin compress -phl";
          desc = "Archive selected files (password+header+level)";
        }
      ];
    };
    settings = {

      plugin.prepend_previewers = [
        {
          mime = "application/{*zip,tar,bzip2,7z*,rar,xz,zstd,java-archive}";
          run = "ouch";
        }
      ];
    };

    initLua = /* lua */ ''
      require("yatline"):setup({
        theme = require("nord"):setup(),
      })
    '';
  };
}
