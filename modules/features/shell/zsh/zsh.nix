{ ... }:
{
  flake.homeModules.zsh =
    { config, lib, ... }:
    let
      colors = import ../../common/theme/_green.nix;
    in
    {
      programs.carapace = {
        enable = true;
        enableZshIntegration = true;
      };

      programs.zsh = {
        enable = true;
        enableCompletion = true;
        completionInit = ''
          autoload -U compinit
          zstyle ':completion:*' menu select
          zstyle ':completion:*' group-name ""
          zstyle ':completion:*' matcher-list 'm:{a-zA-Z}={A-Za-z}'
          compinit
        '';

        autosuggestion = {
          enable = true;
          highlight = "fg=#${colors.grey-light}";
        };

        syntaxHighlighting = {
          enable = true;
          highlighters = [ "brackets" ];
          styles = {
            alias = "fg=#${colors.primary-pale}";
            builtin = "fg=#${colors.info}";
            command = "fg=#${colors.text}";
            comment = "fg=#${colors.grey-light}";
            function = "fg=#${colors.warning}";
            path = "fg=#${colors.info}";
            redirection = "fg=#${colors.yellow}";
            "single-quoted-argument" = "fg=#${colors.success}";
            "double-quoted-argument" = "fg=#${colors.success}";
            "unknown-token" = "fg=#${colors.error}";
          };
        };

        shellAliases =
          let
            flakeDir = "~/flake";
          in
          {
            sw = "nh os switch";
            upd = "nh os switch --update";
            hms = "nh home switch";

            pkgs = "nvim ${flakeDir}/nixos/packages.nix";

            r = "ranger";
            v = "nvim";
            se = "sudoedit";
            microfetch = "microfetch && echo";

            gs = "git status";
            ga = "git add";
            gc = "git commit";
            gp = "git push";

            ".." = "cd ..";
          };

        history = {
          size = 100000;
          save = 100000;
          append = true;
          extended = true;
          share = true;
          path = "${config.xdg.dataHome}/zsh/history";
        };

        initContent = lib.mkOrder 1500 ''
          # Start UWSM
          if uwsm check may-start > /dev/null && uwsm select; then
            exec systemd-cat -t uwsm_start uwsm start default
          fi
        '';
      };
    };
}
