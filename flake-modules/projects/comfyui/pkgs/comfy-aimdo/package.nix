{
  python3Packages,
  comfyuiNpins,
  comfyuiLib,
  cudaPackages,
  autoAddDriverRunpath,
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
  }:
  buildPythonPackage rec {
    pname = "comfy-aimdo";
    inherit (npin) version src;
    format = "pyproject";

    nativeBuildInputs = [
      setuptools
      setuptools-scm
      wheel
      cudaPackages.cuda_nvcc
      autoAddDriverRunpath
    ];

    buildInputs = [
      cudaPackages.cuda_cudart
    ];

    # Manually compile the shared object
    preBuild = ''
      gcc -shared -o comfy_aimdo/aimdo.so -fPIC \
        -I${lib.getDev cudaPackages.cuda_cudart}/include \
        -I${lib.getDev cudaPackages.cuda_nvcc}/include \
        -L${lib.getLib cudaPackages.cuda_cudart}/lib/stubs \
        src/control.c src/debug.c src/model-vbar.c src/pyt-cu-plug-alloc.c -lcuda
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
