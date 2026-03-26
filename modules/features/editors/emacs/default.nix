{ ... }:
{
  flake.homeModules.doom-emacs =
    { pkgs, ... }:
    {
      programs.emacs = {
        enable = true;
        package = pkgs.emacs-pgtk;
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
        isync
        msmtp
        gopass
      ];
    };
}
