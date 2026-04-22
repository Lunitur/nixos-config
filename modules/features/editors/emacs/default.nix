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
          epkgs.treesit-grammars.with-all-grammars
        ];
      };
      services.emacs = {
        enable = true;
        startWithUserSession = "graphical";
      };

      # home.file.".config/doom".source = ./doom;

      home.sessionPath = [ "$HOME/.config/emacs/bin" ];

      home.packages = with pkgs; [
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
