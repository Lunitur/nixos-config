{
  lib,
  rustPlatform,
  fetchFromGitHub,
  pkg-config,
  openssl,
  sqlite,
}:

rustPlatform.buildRustPackage rec {
  pname = "hashcards";
  version = "0.4.0";

  src = fetchFromGitHub {
    owner = "eudoxia0";
    repo = "hashcards";
    rev = "2699292e45b69a12e8966a2cd359e2427aae2c79";
    sha256 = "sha256-KkQwSoLvaiEckyBCryRevUq1HIVZNtBhctEBcfKKHw0=";
  };

  cargoHash = "sha256-qd0cmxiHilyMHSMrX58OMrFANDTT+OCBsCYDbf++BTM=";

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
