{ ... }:
{
  flake.homeModules.yazi =
    {
      config,
      lib,
      pkgs,
      ...
    }:
    {
      programs.yazi = {
        enable = true;
        enableNushellIntegration = true;
        shellWrapperName = "y";

        plugins = with pkgs.yaziPlugins; {
          inherit
            nord
            yatline
            git
            ouch
            compress
            jump-to-char
            smart-enter
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
            {
              on = "<Enter>";
              run = "plugin --sync smart-enter";
              desc = "Enter the child directory, or open the file";
            }
            {
              on = "f";
              run = "plugin jump-to-char";
              desc = "Jump to char";
            }
            {
              on = [
                "c"
                "a"
                "a"
              ];
              run = "plugin compress";
              desc = "Archive selected files";
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
          require("smart-enter"):setup {
          	open_multi = true,
          }
        '';
      };
    };
}
