{ lib
, rustPlatform
, fetchFromGitHub
, fetchzip
, pkg-config
, openssl
, sqlite
}:

let
  katex = fetchzip {
    url = "https://github.com/KaTeX/KaTeX/releases/download/v0.16.25/katex.tar.gz";
    sha256 = "14mz8gdr4ggfq9lsvfrr8mvw2ghls30hwk4q1w63b1x6fmmyy91d";
  };
in
rustPlatform.buildRustPackage rec {
  pname = "hashcards";
  version = "unstable-2025-12-14";

  src = fetchFromGitHub {
    owner = "eudoxia0";
    repo = "hashcards";
    rev = "73fabc22752ebf2ff57216d5d57e3737e2c28492";
    sha256 = "1wr2pym6vzrjamvzp9fdyg1s9w2bvw4rsc6f0lqyxkg3s5hvw5mv";
  };

  cargoHash = "sha256-vo73XFzE8ruGc7o36ugoCFTcJzuioQ7UCcsxFzt3fIg=";

  nativeBuildInputs = [ pkg-config ];
  buildInputs = [ openssl sqlite ];

  preBuild = ''
    mkdir -p vendor/katex
    cp -r ${katex}/* vendor/katex/
    chmod -R u+w vendor/katex
    sed -i 's|fonts/|/katex/fonts/|g' vendor/katex/katex.min.css
  '';

  meta = with lib; {
    description = "A plain text-based spaced repetition system";
    homepage = "https://github.com/eudoxia0/hashcards";
    license = licenses.asl20;
    maintainers = [];
  };
}
