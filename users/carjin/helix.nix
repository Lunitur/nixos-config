{ pkgs, lib, ... }:
{
  programs.helix = {
    enable = true;
    languages = {
      language-server.metals.config.metals = {
        autoImportBuild = "all";
      };

      language-server.texlab.config.texlab = {
        build = {
          onSave = true;
        };
        forwardSearch = {
          executable = "zathura";

          args = [
            "--synctex-forward"
            "%l:1:%f"
            "%p"
          ];
        };
        chktex.onEdit = true;
      };
      language-server.basedpyright = {
        command = "basedpyright-langserver";
        args = [ "--stdio" ];
        except-features = [
          "format"
          "code-action"
        ];
        config.basedpyright.analysis = {
          autoSearchPaths = true;
          typeCheckingMode = "basic";
          diagnosticMode = "openFilesOnly";
        };
      };
      language-server.ruff = {
        command = "ruff";
        args = [
          "server"
          "--preview"
        ];
      };
      language-server.lean-language-server = {
        command = "${pkgs.lean4}/bin/lean";
        args = [ "--server" ];
      };
      language = [
        {
          name = "typst";
          formatter.command = "typstyle";
          auto-format = true;
        }
        {
          name = "latex";
          auto-format = true;
          # config.texlab.build.onSave = true;

        }
        {
          name = "nix";
          auto-format = true;
          formatter.command = "${pkgs.nixfmt-rfc-style}/bin/nixfmt";
        }
        {
          name = "haskell";
          file-types = [
            "hs"
            "lhs"
          ];
          auto-format = true;
          formatter.command = "${pkgs.haskellPackages.ormolu}/bin/ormolu";
          # linter.command = "${pkgs.haskellPackages.hlint}/bin/hlint";
        }
        {
          name = "cpp";
          auto-format = true;
          formatter.command = "clang-format";
          formatter.args = [ "--style=file" ];
        }
        {
          name = "scala";
          auto-format = true;
          # formatter.command = "${pkgs.scalafmt}/bin/scalafmt";
        }
        {
          name = "python";
          language-servers = [
            "basedpyright"
            "ruff"
          ];
          auto-format = true;
        }
        {
          name = "lean";
          scope = "source.lean";
          file-types = [ "lean" ];
          comment-token = "--";
          language-servers = [ "lean-language-server" ];
          roots = [ "lean-toolchain" ];
        }
      ];
    };
    settings = {
      theme = lib.mkForce "tokyonight";
      editor.lsp = {
        display-inlay-hints = true;
      };
      editor.soft-wrap.enable = true;
    };
    themes = {
      autumn_night_transparent = {
        "inherits" = "autumn_night";
        "ui.background" = { };
      };
    };
  };

}
