{ }:
derivation {
  system = "x86_64-linux";
  # Name of the derivation
  name = "my-c-program";

  # Build using the GNU C compiler
  buildInputs = [ "gcc" ];

  # Source code
  src = ./.;

  # Build phase
  build = ''
    gcc -o my-program my-program.c
  '';

  # Install phase
  install = ''
    mkdir -p $out/bin
    cp my-program $out/bin
  '';
}
