{
  lib,
  rustPlatform,
  fetchFromGitHub,
  pkg-config,
  cmake,
  makeWrapper,
  patchelf,
  libevdev,
  libpulseaudio,
  libxkbcommon,
  libgbm,
  libglvnd,
  opus,
  wayland,
  vulkan-headers,
  vulkan-loader,
  shaderc,
  xwayland,
}:

let
  # inputtino-sys builds its C++ library from source via cmake. Its build.rs
  # points cmake at "../../../" (the repo root), but cargo only vendors the
  # crate's own directory, so that path is missing at build time. Provide the
  # full inputtino checkout and repoint cmake at it below.
  inputtinoSrc = fetchFromGitHub {
    owner = "games-on-whales";
    repo = "inputtino";
    rev = "f4ce2b0df536ef309e9ff318f75b460f7097d7c1";
    hash = "sha256-mAAXbIK7aNSLyN7OZX9YeesMvT6OZmT9uAx0md6pyRM=";
  };
in
rustPlatform.buildRustPackage rec {
  pname = "moonshine";
  version = "0.12.0-unstable-2026-07-20";

  src = fetchFromGitHub {
    owner = "hgaiser";
    repo = "moonshine";
    rev = "61530ff2b7ce32a4b012c7df30b8f647095bb68c";
    hash = "sha256-3TpMNNCNwVYZQjQ9hGKUB5YXHWuXeq4NimFCrJLLhZg=";
  };

  # The workspace pulls several dependencies from git, so the vendored
  # Cargo.lock must be provided together with hashes for those sources.
  cargoLock = {
    lockFile = ./Cargo.lock;
    outputHashes = {
      "ash-0.38.0+1.4.329" = "sha256-uUOCdSMoupbiK0QY64bmyMlq2EoL5Atc0HiczCqPhXM=";
      "inputtino-0.1.0" = "sha256-mAAXbIK7aNSLyN7OZX9YeesMvT6OZmT9uAx0md6pyRM=";
      "inputtino-sys-0.1.0" = "sha256-mAAXbIK7aNSLyN7OZX9YeesMvT6OZmT9uAx0md6pyRM=";
      "pixelforge-0.6.0" = "sha256-E4xk52rJM9ee3wPbeSli/aOl6CJVy7M8rOPysEBvEo0=";
      "smithay-0.7.0" = "sha256-AB24k+BMzuke8cPkwbmUBtF+tHCXTYNGfTQ8NSEIFCo=";
    };
  };

  nativeBuildInputs = [
    pkg-config
    cmake
    makeWrapper
    patchelf
    rustPlatform.bindgenHook # LIBCLANG_PATH for inputtino-sys bindgen
  ];

  buildInputs = [
    libevdev
    libpulseaudio
    libxkbcommon
    libgbm
    opus
    wayland
    vulkan-headers
    vulkan-loader
    shaderc
  ];

  # Build the whole workspace, not just the moonshine binary, so the
  # moonshine-wsi Vulkan layer (a cdylib, not a dependency of the binary) is
  # produced too.
  cargoBuildFlags = [ "--workspace" ];

  # shaderc-sys: link against the prebuilt nixpkgs shaderc instead of
  # rebuilding it from source during the cargo build.
  SHADERC_LIB_DIR = "${shaderc.lib}/lib";
  SHADERC_INCLUDE_DIR = "${shaderc.dev}/include";

  # cmake's setup hook interferes with the cargo-driven build; inputtino-sys
  # invokes cmake itself from its build script.
  dontUseCmakeConfigure = true;

  # Repoint inputtino-sys' cmake build at the full inputtino checkout, since
  # the "../../../" relative path it expects is not present in the vendor dir.
  # The vendored crate is copied to a writable $cargoDepsCopy by the cargo
  # setup hook, and git sources carry no per-file checksums, so this is safe.
  # Also drop inputtino-sys' link against LLVM's libc++: everything here is
  # built with gcc, so libstdc++ is the C++ runtime and a second one would
  # both fail to link and risk symbol conflicts at runtime.
  postPatch = ''
    substituteInPlace "$cargoDepsCopy/inputtino-sys-0.1.0/build.rs" \
      --replace-fail 'PathBuf::from("../../../")' 'PathBuf::from("${inputtinoSrc}")' \
      --replace-fail 'println!("cargo:rustc-link-lib=c++");' ""
  '';

  # Requires GPU / Vulkan; nothing to run in the sandbox.
  doCheck = false;

  postInstall = ''
    # These are dlopen'd at runtime (vulkan-loader by the encoder, libEGL/gbm by
    # smithay's EGL backend, wayland/xkbcommon by the compositor), so they must
    # be on the library path rather than linked. The actual GL/Vulkan driver is
    # still resolved via /run/opengl-driver at runtime.
    wrapProgram $out/bin/moonshine \
      --prefix LD_LIBRARY_PATH : "${
        lib.makeLibraryPath [
          vulkan-loader
          libglvnd
          libgbm
          wayland
          libxkbcommon
        ]
      }" \
      --prefix PATH : "${lib.makeBinPath [ xwayland ]}"

    # moonshine-wsi is a cdylib Vulkan implicit layer that is injected into the
    # games moonshine launches (activated via ENABLE_MOONSHINE_WSI=1). cargo
    # builds it but the install hook drops it in $out/lib; move it under a
    # dedicated dir and ship a manifest whose library_path points at that copy.
    # rpath is set in postFixup (see below).
    rm -f "$out/lib/libmoonshine_wsi.so"
    wsi=$(find target -name 'libmoonshine_wsi.so' -print -quit)
    install -Dm755 "$wsi" "$out/lib/moonshine/vulkan-layers/libmoonshine_wsi.so"

    install -Dm644 dist/VkLayer_moonshine_wsi.json \
      "$out/share/vulkan/implicit_layer.d/VkLayer_moonshine_wsi.json"
    substituteInPlace "$out/share/vulkan/implicit_layer.d/VkLayer_moonshine_wsi.json" \
      --replace-fail /usr/lib/moonshine/vulkan-layers/libmoonshine_wsi.so \
        "$out/lib/moonshine/vulkan-layers/libmoonshine_wsi.so"

    # udev rules granting access to /dev/uinput and /dev/uhid (virtual input).
    install -Dm644 dist/60-moonshine.rules "$out/lib/udev/rules.d/60-moonshine.rules"
  '';

  # wayland-client is dlopen'd (wayland-backend "client_system"), so it is not a
  # DT_NEEDED and fixupPhase's rpath shrink would strip it. Re-add the rpath
  # after fixup so the layer resolves libwayland-client inside game processes.
  postFixup = ''
    patchelf --set-rpath "${lib.makeLibraryPath [ wayland ]}" \
      "$out/lib/moonshine/vulkan-layers/libmoonshine_wsi.so"
  '';

  meta = {
    description = "Headless game streaming server for Moonlight clients";
    homepage = "https://github.com/hgaiser/moonshine";
    license = lib.licenses.gpl3Only;
    platforms = lib.platforms.linux;
    mainProgram = "moonshine";
    maintainers = [ ];
  };
}
