{ config, pkgs, ... }:
{
  programs = {
    nushell = {
      enable = true;
      # The config.nu can be anywhere you want if you like to edit your Nushell with Nu
      #      configFile.source = ./.../config.nu;
      # for editing directly to config.nu
      extraConfig = ''
            let carapace_completer = {|spans|
            carapace $spans.0 nushell $spans | from json
            }
            $env.config = {
              hooks: {
                command_not_found: {
                  |cmd_name| try {
                     let dbPath = "/nix/var/nix/profiles/per-user/root/channels/nixos/programs.sqlite"
                     let system = "x86_64-linux"
                     let db = open $dbPath | $in.Programs
                     let program_name = $cmd_name | split words | get 0

                     let list = $db | where system == $system and name == $program_name
                                    | select package
                                    | get package 

                     if ($list | is-empty) {
                       print "No non-local packages found.\n"
                     } else { 
                       let selected_package = $list | input list "Select package";

                       ^nix-shell -p $selected_package
                     #  ^nix-shell --run $"nu -e '($cmd_name)'" -p $selected_package
                     }
                   }
                }
              pre_prompt: [{ ||
                if (which direnv | is-empty) {
                 return
                }

                direnv export json | from json | default {} | load-env
              }]
               
              env_change: {
               #  PWD: {|before, after| if (($"($after)/shell.nix" | path exists) and ($env.IN_NIX_SHELL? | describe) == nothing) { nix-shell --command nu } }
              }

             }
            
             show_banner: false,
             completions: {
               case_sensitive: false # case-sensitive completions
               quick: true    # set to false to prevent auto-selecting completions
               partial: true    # set to false to prevent partial filling of the prompt
               algorithm: "fuzzy"    # prefix or fuzzy
             }
            } 
            $env.PATH = ($env.PATH | 
            split row (char esep) |
        #    prepend /home/myuser/.apps |
            append /usr/bin/env |
            append $"($env.HOME)/System"
            )

            source ($nu.default-config-dir | path join "zoxide.nu")
            source $"($nu.home-path)/nixos/dotfiles/nushell/startup.nu"
            source ($nu.default-config-dir | path join "completers.nu")
            const init_path = $"($nu.home-path)/.init.nu"
            source $init_path

            fastfetch
      '';
      shellAliases = {
        vi = "hx";
        vim = "hx";
        nano = "hx";
        cat = "bat";
        tree = "eza --tree";
        grep = "rga";
        rg = "rga";
      };
    };
    carapace.enable = true;
    carapace.enableNushellIntegration = true;

    starship = {
      enable = true;
      settings = {
        add_newline = true;
        character = {
          success_symbol = "[➜](bold green)";
          error_symbol = "[➜](bold red)";
        };
      };
    };
  };
}
