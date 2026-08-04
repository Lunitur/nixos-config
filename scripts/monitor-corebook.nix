{ pkgs }:

pkgs.writeShellScriptBin "rotate-screen-corebook" ''
  ${pkgs.wlr-randr}/bin/wlr-randr --output DSI-1 --transform 270

''
