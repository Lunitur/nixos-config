{ pkgs, ... }:
{
  home.packages = with pkgs; [
    jupyter-all
    # ihaskell
  ];

  systemd.user.services.jupyter = {
    Unit = {
      Description = "Jupyter Lab Development Environment";
    };
    Install = {
      WantedBy = [ "graphical-session.target" ];
    };
    Service = {
      type = "Simple";
      ExecStart = "${pkgs.jupyter-all}/bin/jupyter-lab";
      Restart = "always";
      RestartSec = 3;
    };
  };
}
