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
