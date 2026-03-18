{ ... }:
{
  flake.homeModules.distrobox =
    {
      config,
      lib,
      pkgs,
      ...
    }:
    let
      inherit (builtins) concatStringsSep filter typeOf;
      # inherit (import ./scripts pkgs) box; # This might be broken now, let's check path

      mkBox =
        name:
        {
          image,
          exec ? "${pkgs.nushell}/bin/nu",
          packages ? [ ],
        }:
        let
          distropkgs = concatStringsSep " " (
            filter (p: typeOf p == "string") (
              packages
              ++ [
                "wl-clipboard"
                "git"
              ]
            )
          );

          path = [
            "/bin"
            "/sbin"
            "/usr/bin"
            "/usr/sbin"
            "/usr/local/bin"
            "$HOME/.local/bin"
          ]
          ++ [
            "${pkgs.helix}/bin"
            "${pkgs.nushell}/bin"
          ]
          ++ (map (p: "${p}/bin") (filter (p: typeOf p == "set") packages));

          db-exec = pkgs.writeShellScript "db-exec" ''
            export XDG_DATA_DIRS="/usr/share:/usr/local/share"
            export PATH="${builtins.concatStringsSep ":" path}"
            if [ $# -eq 0 ]; then ${exec}; else bash -c "$@"; fi
          '';
        in
        pkgs.writeShellScriptBin name ''
          distrobox enter ${name} -- ${db-exec} $@
        '';
    in
    {
      home.packages = [
        pkgs.distrobox
        (mkBox "ubuntu" {
          image = "quay.io/toolbx/ubuntu-toolbox:latest";
        })
        (mkBox "alpine" {
          image = "docker.io/library/alpine:latest";
        })
      ];
    };
}
