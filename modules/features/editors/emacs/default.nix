{ ... }:
{
  flake.homeModules.doom-emacs =
    { pkgs, ... }:
    {
      programs.emacs = {
        enable = true;
        package = pkgs.emacs-pgtk;
      };
      services.emacs.enable = true;

      # home.file.".config/doom".source = ./doom;

      home.sessionPath = [ "$HOME/.config/emacs/bin" ];

      home.packages = with pkgs; [
        ripgrep
        coreutils
        fd
      ];
    };
}
