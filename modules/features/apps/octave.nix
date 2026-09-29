{ ... }:
{
  flake.homeModules.octave =
    { pkgs, ... }:
    let
      octaveEnv = pkgs.octaveFull.withPackages (
        op: with op; [
          general
          control
          signal
          communications
          statistics
          nan
          optim
          io
          image
          video
          audio
          struct
          datatypes
          miscellaneous
          strings
          geometry
          matgeom
          symbolic
          financial
        ]
      );
    in
    {
      home.packages = with pkgs; [
        octaveEnv
        gnuplot
      ];
    };
}
