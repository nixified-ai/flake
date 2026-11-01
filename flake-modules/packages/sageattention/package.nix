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
  ninja,
  COMFY_CUDA_ARCHS,
  gcc14Stdenv,
}:
let
  cuda-native-redist = symlinkJoin {
    name = "cuda-redist";
    paths = with cudaPackages; [
      cuda_cudart # cuda_runtime.h
      cuda_nvcc
    ];
  };
in
buildPythonPackage rec {
  pname = "sageattention";
  format = "setuptools";

  env.CUDA_HOME = "${cuda-native-redist}";
  env.CUDA_VERSION = cudaPackages.cudaMajorMinorVersion;
  env.TORCH_CUDA_ARCH_LIST = COMFY_CUDA_ARCHS;
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

  dontUseNinjaBuild = true;
  nativeBuildInputs = [
    ninja
  ];

  build-system = [
    setuptools
    wheel
  ];

  preBuild = ''
    export PATH=${gcc14Stdenv.cc}/bin:$PATH
    substituteInPlace setup.py --replace-fail "-std=c++17" "-std=c++20"
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
