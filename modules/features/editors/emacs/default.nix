{ ... }:
{
  flake.homeModules.doom-emacs =
    { pkgs, ... }:
    {
      programs.emacs = {
        enable = true;
        package = pkgs.emacs-pgtk;
        extraPackages = epkgs: [
          pkgs.mu
          pkgs.mu.mu4e
          epkgs.vterm
        ];
      };
      services.emacs = {
        enable = true;
        startWithUserSession = "graphical";
      };
      systemd.user.services.emacs.Service.EnvironmentFile = "%h/Nextcloud/env/emacs.env";

      # home.file.".config/doom".source = ./doom;
      home.file.".config/emacs/.local/etc/tree-sitter".source =
        "${pkgs.emacsPackages.treesit-grammars.with-all-grammars}/lib";

      home.sessionPath = [ "$HOME/.config/emacs/bin" ];

      home.packages = with pkgs; [
        gcc
        ripgrep
        coreutils
        fd
        mu
        mu.mu4e
        isync
        msmtp
        gopass
      ];
    };
}
