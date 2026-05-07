{ ... }:
{
  flake.homeModules.nushell =
    {
      osConfig,
      pkgs,
      ...
    }:
    {
      programs = {
        nushell = {
          enable = true;
          settings = {
            edit_mode = "vi";
          };
          extraConfig = ''

            $env.config = {
              show_banner: false
              completions: {
                case_sensitive: false
                quick: true
                partial: true
                algorithm: "fuzzy"
                external: {
                  enable: true
                }
              }
              keybindings: [
                {
                  name: "run_in_bash"
                  modifier: "control"
                  keycode: "char_b"
                  mode: ["emacs", "vi_insert", "vi_normal"]
                  event: [
                    {
                      send: "executehostcommand"
                      cmd: 'let cmd = (commandline); if not ($cmd | is-empty) { bash -c $cmd; commandline edit --replace "" }'
                    }
                  ]
                }
              ]
            }

            # $env.config.hooks.command_not_found =  source ${pkgs.nix-index}/etc/profile.d/command-not-found.nu
            source ${pkgs.comma}/share/comma/command-not-found.nu

            $env.PATH = (
              $env.PATH
              | split row (char esep)
              | append "/usr/bin"
              | append $"($env.HOME)/.config/emacs/bin"
              | uniq
            )

            $env.CARAPACE_BRIDGES = 'fish,zsh,bash'

            ${import ./_zoxide.nix}
            ${import ./_startup.nix}

            const init_path = $"($nu.home-path)/.init.nu"
            if not ($init_path | path exists) {
              touch $init_path
            }
            source $init_path
          '';
          shellAliases = {
            vi = "hx";
            vim = "hx";
            nano = "hx";
            cat = "bat";
            tree = "eza --tree";
            grep = "rga";
            rg = "rga";
            pkgs = "hx ~/nixos/users/carjin/packages.nix";
            nixos-switch = "nh os switch ~/nixos";
            nixos = "hx ~/nixos";
            lls = "ls -l | reject target num_links inode readonly created accessed";
            nix-repl = "nixos-rebuild repl --flake ~/nixos#${osConfig.networking.hostName}";
            nix-eval = "nix eval ~/nixos/#nixosConfigurations.${osConfig.networking.hostName}.config.system.build.toplevel.drvPath";
            nh-victus = "nh os switch ~/nixos -- --substituters \"http://cache.nixos.org http://victus\" ";
            em = "emacsclient -t";
            gpro = "gemini -m gemini-3.1-pro-preview --include-directories ~/nixos";
            gflash = "gemini -m gemini-3-flash-preview --include-directories ~/nixos";
            cpro = "claude --allow-dangerously-skip-permissions --permission-mode bypassPermissions --model deepseek-v4-pro[1m]";
            cflash = "claude --allow-dangerously-skip-permissions --permission-mode bypassPermissions --model deepseek-v4-flash";
          };
        };
        carapace.enable = true;
        carapace.enableNushellIntegration = true;
      };
      home.packages = with pkgs; [ zoxide ];
    };
}
