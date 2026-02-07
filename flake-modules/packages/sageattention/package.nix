{
  buildPythonPackage,
  fetchFromGitHub,
  setuptools,
  wheel,
  torch,
  triton,
  cudaPackages,
  symlinkJoin,
  gnused,
}:
let
  cuda-native-redist = symlinkJoin {
    name = "cuda-redist";
    paths = with cudaPackages; [
      cuda_cudart # cuda_runtime.h
      cuda_nvcc
    ];
    postBuild = ''
      # Patch math_functions.h and math_functions.hpp to fix conflict with glibc 2.42+
      header="$out/include/crt/math_functions.h"
      hpp="$out/include/crt/math_functions.hpp"

      # Patch .h file
      if [ -e "$header" ]; then
        echo "Patching $header..."
        cp --remove-destination "$(readlink -f "$header")" "$header"
        chmod +w "$header"
        for func in sinpi sinpif cospi cospif rsqrt rsqrtf; do
          ${gnused}/bin/sed -i "s/\($func(.\+)\);/\1 noexcept (true);/" "$header"
        done
        if ! grep -q "sinpi(double x) noexcept (true);" "$header"; then
          echo "Failed to patch $header"
          exit 1
        fi
      fi

      # Patch .hpp file to match .h exception specifications
      if [ -e "$hpp" ]; then
        echo "Patching $hpp..."
        cp --remove-destination "$(readlink -f "$hpp")" "$hpp"
        chmod +w "$hpp"

        # Add noexcept(true) to the C++ wrappers
        # Matches: __MATH_FUNCTIONS_DECL__ float rsqrt(const float a)
        ${gnused}/bin/sed -i 's/__MATH_FUNCTIONS_DECL__ float rsqrt(const float a)/__MATH_FUNCTIONS_DECL__ float rsqrt(const float a) noexcept (true)/' "$hpp"
        ${gnused}/bin/sed -i 's/__MATH_FUNCTIONS_DECL__ float sinpi(const float a)/__MATH_FUNCTIONS_DECL__ float sinpi(const float a) noexcept (true)/' "$hpp"
        ${gnused}/bin/sed -i 's/__MATH_FUNCTIONS_DECL__ float cospi(const float a)/__MATH_FUNCTIONS_DECL__ float cospi(const float a) noexcept (true)/' "$hpp"
        ${gnused}/bin/sed -i 's/__MATH_FUNCTIONS_DECL__ void sincospi(const float a, float \*const sptr, float \*const cptr)/__MATH_FUNCTIONS_DECL__ void sincospi(const float a, float *const sptr, float *const cptr) noexcept (true)/' "$hpp"

        if ! grep -q "rsqrt(const float a) noexcept (true)" "$hpp"; then
           echo "Failed to patch $hpp"
           exit 1
        fi
      fi
    '';
  };
in
buildPythonPackage rec {
  pname = "sageattention";
  format = "setuptools";

  CUDA_HOME = cuda-native-redist;
  CUDA_VERSION = cudaPackages.cudaMajorMinorVersion;
  env.TORCH_CUDA_ARCH_LIST = "8.6";
  version = "unstable-2025-07-21";

  src = fetchFromGitHub {
    owner = "thu-ml";
    repo = "SageAttention";
    rev = "628a89f1619b474ef2ed735b1e907ebca57fc1cd";
    hash = "sha256-19fhfXANHv3Mzy4q+1ISUaTOBq7Q9A8im01ILiui8Ho=";
  };

  propagatedBuildInputs = [
    torch
    triton
  ];

  buildInputs = [
    cudaPackages.cudatoolkit
  ];

  build-system = [
    setuptools
    wheel
  ];

  preBuild = ''
    ${gnused}/bin/sed -i "/compute_capabilities = set()/a compute_capabilities = {\"$TORCH_CUDA_ARCH_LIST\"}" setup.py
  '';

  pythonImportsCheck = [
    "sageattention"
  ];

  meta = {
    description = "This repository provides the official implementation of SageAttention, SageAttention2, and SageAttention2++, which achieve surprising speedup on most GPUs without lossing accuracy across all models in a plug-and-play way.";
    homepage = "https://github.com/thu-ml/SageAttention";
  };
}
