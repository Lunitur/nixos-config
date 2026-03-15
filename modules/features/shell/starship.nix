{ config,
lib,
...
}:
let
  cfg = config.features.shell.starship;
in
{
  options.features.shell.starship.enable = lib.mkEnableOption "Starship prompt";

  config = lib.mkIf cfg.enable {
    home-manager.users.carjin = {
      programs.starship = {
        enable = true;
        enableZshIntegration = true;
        settings = {
          format = lib.concatStrings [
            "$username"
            "$hostname"
            "$directory"
            "$git_branch"
            "$git_state"
            "$git_status"
            "$nix_shell"
            "$fill"
            "$status"
            "$line_break"
            "$character"
          ];

          fill.symbol = " ";
          hostname.ssh_symbol = "";
          rust.symbol = " ";
          status.disabled = false;
          username.format = "[$user]($style)@";

          character = {
            success_symbol = "[❯](green)";
            error_symbol = "[❯](red)";
            vicmd_symbol = "[❯](green)";
          };

          directory = {
            read_only = " 󰌾";
            home_symbol = " ~";
            style = "blue";
            truncate_to_repo = false;
            truncation_length = 5;
            truncation_symbol = ".../";
          };

          docker_context.symbol = " ";

          git_branch = {
            symbol = "󰊢 ";
            format = "[󰊢 $branch]($style)";
            style = "green";
          };

          git_status = {
            format = "[[( $conflicted$untracked$modified$staged$renamed$deleted)](blue) ($ahead_behind$stashed)](green)";
            conflicted = "​=$count ";
            untracked = "​?$count ";
            modified = "​!$count ";
            staged = "​+$count ";
            renamed = "»$count ​";
            deleted = "​​-$count ";
            stashed = "≡";
          };

          git_state = {
            format = "\([$state( $progress_current/$progress_total)]($style)\) ";
            style = "bright-black";
          };

          golang = {
            symbol = " ";
            format = "[$symbol$version](cyan bold) ";
          };

          kubernetes = {
            disabled = false;
            format = "[$symbol$context](cyan bold) ";
          };

          nix_shell = {
            disabled = false;
            symbol = "❄️ ";
            format = "via [$symbol\( $name\)]($style)";
          };
        };
      };
    };
  };
}
