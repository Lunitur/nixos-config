{
  lib,
  stdenv,
  stdenvNoCC,
  fetchurl,
  autoPatchelfHook,
  makeWrapper,
  android-tools,
}:

stdenvNoCC.mkDerivation rec {
  pname = "madbfs";
  version = "0.12.0";

  # The release includes the Android helper binaries for proxy transport.
  src = fetchurl {
    url = "https://github.com/mrizaln/madbfs/releases/download/v${version}/madbfs.tar.gz";
    hash = "sha256-a7eszgDoTEf2TkXfoga3+nOPfZTHi4Be37v8kPWst3c=";
  };

  nativeBuildInputs = [
    autoPatchelfHook
    makeWrapper
  ];
  buildInputs = [ stdenv.cc.cc.lib ];

  dontConfigure = true;
  dontBuild = true;

  installPhase = ''
    runHook preInstall
    install -Dm755 madbfs "$out/bin/madbfs"
    install -Dm755 madbfs-msg "$out/bin/madbfs-msg"
    runHook postInstall
  '';

  postFixup = ''
    wrapProgram "$out/bin/madbfs" \
      --prefix PATH : "${lib.makeBinPath [ android-tools ]}"
  '';

  meta = {
    description = "Mount Android storage through ADB using FUSE";
    homepage = "https://github.com/mrizaln/madbfs";
    license = lib.licenses.mit;
    platforms = [ "x86_64-linux" ];
    mainProgram = "madbfs";
    sourceProvenance = [ lib.sourceTypes.binaryNativeCode ];
  };
}
