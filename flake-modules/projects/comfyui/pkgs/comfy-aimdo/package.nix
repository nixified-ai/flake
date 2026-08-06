{
  python3Packages,
  comfyuiNpins,
  comfyuiLib,
  cudaPackages,
  autoAddDriverRunpath,
  config,
}:
let
  npin = comfyuiLib.nodePropsFromNpinSource comfyuiNpins.comfy-aimdo;
in
python3Packages.callPackage (
  {
    buildPythonPackage,
    lib,
    setuptools,
    setuptools-scm,
    wheel,
    fetchurl,
    cmake,
  }:
  buildPythonPackage rec {
    pname = "comfy-aimdo";
    inherit (npin) version src;
    format = "pyproject";
    dontUseCmakeConfigure = true;

    funchookTarball = fetchurl {
      url = "https://github.com/kubo/funchook/releases/download/v1.1.3/funchook-1.1.3.tar.gz";
      sha256 = "1xafrbdcr4i94gafkwzfs5gw8dzfrxz9c1p0nrrw31i3blpni7fl";
    };

    nativeBuildInputs = [
      setuptools
      setuptools-scm
      wheel
    ]
    ++ lib.optionals config.cudaSupport [
      cudaPackages.cuda_nvcc
      autoAddDriverRunpath
      cmake
    ];

    buildInputs = lib.optional config.cudaSupport cudaPackages.cuda_cudart;

    preBuild = lib.optionalString config.cudaSupport ''
      mkdir -p build
      tar -xzf ${funchookTarball} -C build
      patchShebangs scripts/build-linux-aimdo.sh
      AIMDO_EXTRA_CFLAGS="-I${lib.getDev cudaPackages.cuda_cudart}/include -I${lib.getDev cudaPackages.cuda_nvcc}/include -L${lib.getLib cudaPackages.cuda_cudart}/lib/stubs" \
      bash ./scripts/build-linux-aimdo.sh
    '';

    meta = with lib; {
      description = "AI Model Dynamic Offloader for ComfyUI";
      homepage = "https://github.com/Comfy-Org/comfy-aimdo";
      license = licenses.asl20;
      maintainers = with maintainers; [ ];
      platforms = platforms.linux;
    };
  }
) { }
