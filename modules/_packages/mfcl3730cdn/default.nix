{
  pkgsi686Linux,
  stdenv,
  fetchurl,
  libarchive,
  makeWrapper,
  coreutils,
  file,
  ghostscript,
  gnugrep,
  gnused,
  which,
  perl,
  lib,
}:

let
  model = "mfcl3730cdn";
  version = "1.0.2-1";
  src = fetchurl {
    url = "https://download.brother.com/welcome/dlf103956/${model}pdrv-${version}.i386.rpm";
    hash = "sha256-MI4Rtxz3OJkfExxSNzsMN800Lsc9kt/B0Nlx+6D7nJ8=";
  };
  reldir = "opt/brother/Printers/${model}/";
  unpackPhase = ''
    mkdir -p "$out"
    bsdtar -xf "$src" -C "$out"
  '';

in
rec {
  driver = pkgsi686Linux.stdenv.mkDerivation rec {
    inherit src unpackPhase version;
    name = "${model}drv-${version}";

    nativeBuildInputs = [
      libarchive
      makeWrapper
    ];

    installPhase = ''
      dir="$out/${reldir}"
      substituteInPlace "$dir/lpd/filter_${model}" \
        --replace-fail /usr/bin/perl ${perl}/bin/perl \
        --replace-fail /usr/bin/pdf2ps ${ghostscript}/bin/pdf2ps \
        --replace-fail "BR_PRT_PATH =~" "BR_PRT_PATH = \"$dir\"; #" \
        --replace-fail "PRINTER =~" "PRINTER = \"${model}\"; #"
      wrapProgram "$dir/lpd/filter_${model}" \
        --prefix PATH : ${
          lib.makeBinPath [
            coreutils
            file
            ghostscript
            gnugrep
            gnused
            which
          ]
        }

      mkdir -p "$out/bin"
      mv "$out/usr/bin/brprintconf_${model}" "$out/bin/"
      # The 32-bit binaries look up their resources under /opt/brother.
      interpreter=$(cat "$NIX_CC/nix-support/dynamic-linker")
      for binary in "$dir/lpd/br${model}filter" "$out/bin/brprintconf_${model}"; do
        patchelf --set-interpreter "$interpreter" "$binary"
        wrapProgram "$binary" \
          --set LD_PRELOAD ${pkgsi686Linux.libredirect}/lib/libredirect.so \
          --set NIX_REDIRECTS "/opt/brother=$out/opt/brother"
      done
    '';

    meta = {
      description = "Brother ${lib.strings.toUpper model} driver";
      homepage = "http://www.brother.com/";
      sourceProvenance = with lib.sourceTypes; [ binaryNativeCode ];
      license = lib.licenses.unfree;
      platforms = [
        "x86_64-linux"
        "i686-linux"
      ];
      maintainers = [ lib.maintainers.Lunitur ];
    };
  };

  cupswrapper = stdenv.mkDerivation rec {
    inherit src unpackPhase version;
    name = "${model}cupswrapper-${version}";

    nativeBuildInputs = [
      libarchive
      makeWrapper
    ];

    installPhase = ''
      basedir=${driver}/${reldir}
      dir=$out/${reldir}
      substituteInPlace "$dir/cupswrapper/brother_lpdwrapper_${model}" \
        --replace-fail /usr/bin/perl ${perl}/bin/perl \
        --replace-fail "basedir =~" "basedir = \"$basedir\"; #" \
        --replace-fail "PRINTER =~" "PRINTER = \"${model}\"; #" \
        --replace-fail '$CUPSINPUT=$ARGV[7];' 'open(STDIN, "<", $ARGV[5]) or die "Cannot open print job: $!";' \
        --replace-fail 'cp  $basedir/inf/br' 'install -m 600 $basedir/inf/br' \
        --replace-fail '"-qm"       =>  "UseDeviceSettings"    ,' '# Quiet mode is unsupported on this model.'
      wrapProgram "$dir/cupswrapper/brother_lpdwrapper_${model}" \
        --prefix PATH : ${
          lib.makeBinPath [
            coreutils
            driver
            gnugrep
            gnused
          ]
        }
      mkdir -p "$out/lib/cups/filter" "$out/share/cups/model"
      ln "$dir/cupswrapper/brother_lpdwrapper_${model}" "$out/lib/cups/filter"
      ln "$dir/cupswrapper/brother_${model}_printer_en.ppd" "$out/share/cups/model"
    '';

    meta = {
      description = "Brother ${lib.strings.toUpper model} CUPS wrapper driver";
      homepage = "http://www.brother.com/";
      sourceProvenance = with lib.sourceTypes; [ binaryNativeCode ];
      license = lib.licenses.gpl2Plus;
      platforms = [
        "x86_64-linux"
        "i686-linux"
      ];
      maintainers = [ lib.maintainers.Lunitur ];
    };
  };
}
