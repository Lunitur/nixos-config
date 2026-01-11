{
  lib,
  rustPlatform,
  fetchFromGitHub,
  fetchzip,
  pkg-config,
  openssl,
  sqlite,
}:

rustPlatform.buildRustPackage rec {
  pname = "hashcards";
  version = "0.3.0";

  src = fetchFromGitHub {
    owner = "eudoxia0";
    repo = "hashcards";
    rev = "1513a749c6fd5ff05f0b2038002e08718cf1d4ce";
    sha256 = "sha256-6ElKZ5/QJO6TYg9MQfLv2f4Gbj8yu4igERuHa+xGC4Q=";
  };

  cargoHash = "sha256-d41ThobHMEWoLCjYGybHP7FVmUmO+Hi6qkp30/R1baE=";

  nativeBuildInputs = [ pkg-config ];
  buildInputs = [
    openssl
    sqlite
  ];

  # Disables `cargo test`
  doCheck = false;

  meta = with lib; {
    description = "A plain text-based spaced repetition system";
    homepage = "https://github.com/eudoxia0/hashcards";
    license = licenses.asl20;
    maintainers = [ ];
  };
}
