{
  python3Packages,
  comfyuiNpins,
  comfyuiLib,
  cudaPackages,
}:
let
  npin = comfyuiLib.nodePropsFromNpinSource comfyuiNpins.comfy-kitchen;
in
python3Packages.callPackage (
  {
    buildPythonPackage,
    lib,
    setuptools,
    wheel,
    nanobind,
    cmake,
    ninja,
  }:
  buildPythonPackage {
    pname = "comfy-kitchen";
    inherit (npin) version src;
    format = "pyproject";

    nativeBuildInputs = [
      cmake
      ninja
      # which
      cudaPackages.cuda_nvcc
      setuptools
      wheel
      nanobind
    ];

    buildInputs = [
      cudaPackages.cuda_cudart
      cudaPackages.libcublas
    ];

    # Force CUDA architecture 8.6 (Ampere)
    env.COMFY_CUDA_ARCHS = "86";

    # Disable standard CMake configure phase as setup.py handles it
    dontUseCmakeConfigure = true;

    postPatch = ''
      # 1. Patch setup.py to read COMFY_CUDA_ARCHS env var for default archs
      # match the whole assignment to be safe about quotes
      substituteInPlace setup.py \
        --replace-fail 'DEFAULT_CUDA_ARCHS_LINUX = "75-virtual;80;89;90a;100f;120f"' \
                       'DEFAULT_CUDA_ARCHS_LINUX = os.environ.get("COMFY_CUDA_ARCHS", "75-virtual;80;89;90a;100f;120f")'

      # 2. Relax CUDA version check in setup.py (12.8 -> 11.0)
      substituteInPlace setup.py \
        --replace-fail 'lowest_cuda_version = (12, 8)' 'lowest_cuda_version = (11, 0)'

      # 3. Relax CUDA version check in CMakeLists.txt
      substituteInPlace comfy_kitchen/backends/cuda/CMakeLists.txt \
        --replace-fail 'VERSION_LESS "12.8"' 'VERSION_LESS "11.0"' \
        --replace-fail 'requires CUDA 12.8' 'requires CUDA 11.0'

      # 4. Patch cublaslt_runtime.h to find the Nix store path for libcublasLt
      LIB_CUBLASLT="${cudaPackages.libcublas.lib}/lib/libcublasLt.so"

      # Use sed for complex replacement to ensure quotes are handled correctly
      sed -i "s|\"libcublasLt.so.13\",|\"$LIB_CUBLASLT\", \"libcublasLt.so.12\", \"libcublasLt.so.11\", \"libcublasLt.so.13\",|g" comfy_kitchen/backends/cuda/cublaslt_runtime.h
    '';

    preConfigure = ''
      export CUDA_HOME=${cudaPackages.cuda_nvcc}
    '';

    meta = with lib; {
      description = "Fast Kernel Library for ComfyUI with multiple compute backends";
      homepage = "https://github.com/Comfy-Org/comfy-kitchen";
      license = licenses.asl20;
    };
  }
) { }
