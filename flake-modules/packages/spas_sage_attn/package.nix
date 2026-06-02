{
  buildPythonPackage,
  fetchFromGitHub,
  setuptools,
  wheel,
  torch,
  triton,
  einops,
  numpy,
  packaging,
  pybind11,
  tqdm,
  cudaPackages ? { },
  symlinkJoin,
  gnused,
  COMFY_CUDA_ARCHS ? "",
  gcc14Stdenv,
  config,
  lib,
  cudaSupport ? config.cudaSupport,
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
  pname = "spas_sage_attn";
  version = "unstable-2025-05-29";
  format = "setuptools";

  env.CUDA_HOME = if cudaSupport then "${cuda-native-redist}" else "";
  env.CUDA_VERSION = if cudaSupport then cudaPackages.cudaMajorMinorVersion else "";
  env.TORCH_CUDA_ARCH_LIST = COMFY_CUDA_ARCHS;

  src = fetchFromGitHub {
    owner = "woct0rdho";
    repo = "SpargeAttn";
    rev = "067d80cb6b76345c7b8be40e86c7d19a3cf7c4eb";
    hash = "sha256-fDBLhJ2RfIz7XOvEhRJ1rF5oIgugq0pYipLI0MSmzPU=";
  };

  propagatedBuildInputs = [
    torch
    triton
    einops
    numpy
    packaging
    pybind11
    tqdm
  ];

  buildInputs = lib.optionals cudaSupport [
    cudaPackages.cudatoolkit
  ];

  build-system = [
    setuptools
    wheel
  ];

  preBuild = ''
    export PATH=${gcc14Stdenv.cc}/bin:$PATH
  '';

  pythonImportsCheck = lib.optionals cudaSupport [
    "spas_sage_attn"
  ];

  meta = {
    description = "Fork of SpargeAttention (SparseSageAttention)";
    homepage = "https://github.com/woct0rdho/SpargeAttn";
    broken = !cudaSupport;
  };
}
