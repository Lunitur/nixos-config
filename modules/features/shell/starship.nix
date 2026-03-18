{ ... }:
{
  flake.homeModules.starship =
    {
      config,
      lib,
      ...
    }:
    let
      colors = import ../common/theme/_green.nix;
    in
    {
      programs.starship = {
        enable = true;
        enableZshIntegration = true;
        enableNushellIntegration = true;
        enableBashIntegration = true;
        settings = {
          # Use a custom palette based on the theme
          palette = lib.mkForce "night_green";

          palettes.night_green = {
            primary = "#${colors.primary}";
            secondary = "#${colors.secondary}";
            text = "#${colors.text}";
            info = "#${colors.info}";
            warning = "#${colors.warning}";
            error = "#${colors.error}";
            success = "#${colors.success}";
            yellow = "#${colors.yellow}";
            purple = "#${colors.warning}";
            grey = "#${colors.grey}";
          };

          format = lib.concatStrings [
            "$os"
            "$username"
            "$hostname"
            "$directory"
            "$git_branch"
            "$git_state"
            "$git_status"
            "$c"
            "$elixir"
            "$elm"
            "$golang"
            "$haskell"
            "$java"
            "$julia"
            "$nodejs"
            "$nim"
            "$rust"
            "$scala"
            "$nix_shell"
            "$fill"
            "$cmd_duration"
            "$status"
            "$line_break"
            "$character"
          ];

          fill.symbol = " ";

          os = {
            disabled = false;
            symbols = {
              NixOS = " ";
            };
            style = "info";
          };

          username = {
            show_always = true;
            style_user = "yellow bold";
            style_root = "error bold";
            format = "[$user]($style)";
          };

          hostname = {
            ssh_only = true;
            ssh_symbol = "󰣀 ";
            style = "text dimmed";
            format = "@[$hostname]($style) ";
          };

          directory = {
            read_only = " 󰌾";
            home_symbol = " ~";
            style = "info bold";
            truncate_to_repo = true;
            truncation_length = 3;
            truncation_symbol = "./";
            format = " in [$path]($style)[$read_only]($read_only_style) ";
          };

          git_branch = {
            symbol = "󰊢 ";
            style = "warning bold";
            format = "on [$symbol$branch]($style) ";
          };

          git_status = {
            format = "([$all_status$ahead_behind]($style)) ";
            style = "info bold";
            conflicted = "=$count ";
            ahead = "⇡$count ";
            behind = "⇣$count ";
            diverged = "⇕⇡$ahead_count⇣$behind_count ";
            untracked = "?$count ";
            stashed = "≡$count ";
            modified = "!$count ";
            staged = "+$count ";
            renamed = "»$count ";
            deleted = "✘$count ";
          };

          git_state = {
            format = "\([$state( $progress_current/$progress_total)]($style)\) ";
            style = "grey";
          };

          nix_shell = {
            symbol = "❄️ ";
            style = "info bold";
            format = "via [$symbol$state( \($name\))]($style) ";
          };

          cmd_duration = {
            min_time = 500;
            style = "yellow bold";
            format = "took [$duration]($style) ";
          };

          status = {
            disabled = false;
            symbol = "✘";
            format = "[$symbol $status]($style) ";
          };

          character = {
            success_symbol = "[❯](primary bold)";
            error_symbol = "[❯](error bold)";
            vicmd_symbol = "[❮](secondary bold)";
          };

          # Language specific improvements using the palette
          rust = {
            symbol = " ";
            style = "error bold"; # Rust is usually reddish
          };
          golang = {
            symbol = " ";
            style = "info bold";
          };
          elixir = {
            symbol = " ";
            style = "purple bold";
          };
          haskell = {
            symbol = " ";
            style = "purple bold";
          };
          nodejs = {
            symbol = "󰎙 ";
            style = "success bold";
          };
          docker_context.symbol = " ";
          kubernetes.disabled = false;
        };
      };
    };
}
