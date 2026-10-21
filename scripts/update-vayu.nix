{ pkgs }:
pkgs.writeShellApplication {
  name = "update-vayu";
  runtimeInputs = with pkgs; [
    coreutils
    gawk
    jq
    nix
    openssh
  ];
  text = builtins.readFile ./update-vayu.sh;
}
