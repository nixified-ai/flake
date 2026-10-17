{
  python3Packages,
  comfyuiNpins,
  comfyuiLib,
  config,
  stdenv,
  fetchurl,
  cmake,
}:
let
  npin = comfyuiLib.nodePropsFromNpinSource comfyuiNpins.comfy-aimdo;

  # Static funchook (with its bundled distorm disassembler), as built by
  # upstream's scripts/build-linux-aimdo.sh.
  funchook = stdenv.mkDerivation rec {
    pname = "funchook";
    version = "1.1.3";

    src = fetchurl {
      url = "https://github.com/kubo/funchook/releases/download/v${version}/funchook-${version}.tar.gz";
      hash = "sha256-1J1oL10jhsFztuAGln7P7jfEX9Hu8+nUIymSzNrKTvU=";
    };

    nativeBuildInputs = [ cmake ];

    cmakeFlags = [
      "-DCMAKE_POLICY_VERSION_MINIMUM=3.5"
      "-DCMAKE_POSITION_INDEPENDENT_CODE=ON"
      "-DFUNCHOOK_BUILD_SHARED=OFF"
      "-DFUNCHOOK_BUILD_STATIC=ON"
      "-DFUNCHOOK_BUILD_TESTS=OFF"
      "-DFUNCHOOK_DISASM=distorm"
      "-DFUNCHOOK_INSTALL=OFF"
    ];

    installPhase = ''
      mkdir -p $out/lib $out/include
      cp libfunchook.a libdistorm.a $out/lib/
      cp ../include/funchook.h $out/include/
    '';
  };
in
python3Packages.callPackage (
  {
    buildPythonPackage,
    lib,
    setuptools,
    setuptools-scm,
    wheel,
  }:
  buildPythonPackage rec {
    pname = "comfy-aimdo";
    inherit (npin) version src;
    format = "pyproject";

    nativeBuildInputs = [
      setuptools
      setuptools-scm
      wheel
    ];

    # Manually compile the shared object, mirroring upstream's
    # scripts/build-linux-aimdo.sh. libcuda is not linked: aimdo looks up
    # the copy already loaded by torch at runtime.
    preBuild = lib.optionalString config.cudaSupport ''
      gcc -shared -o comfy_aimdo/aimdo.so -fPIC -O2 -pthread \
        -DAIMDO_CUDA \
        src/*.c src-cuda/dispatch.c src-posix/*.c \
        -Isrc -I${funchook}/include \
        ${funchook}/lib/libfunchook.a ${funchook}/lib/libdistorm.a \
        -ldl
    '';

    passthru = { inherit funchook; };

    meta = with lib; {
      description = "AI Model Dynamic Offloader for ComfyUI";
      homepage = "https://github.com/Comfy-Org/comfy-aimdo";
      license = licenses.asl20;
      maintainers = with maintainers; [ ];
      platforms = platforms.linux;
    };
  }
) { }
