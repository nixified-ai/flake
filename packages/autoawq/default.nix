{ lib
, buildPythonPackage
, fetchFromGitHub
, torch
, tokenizers
, sentencepiece
, lm-eval
, texttable
, toml
, attributedict
, protobuf
, torchvision
, tabulate
, cudaPackages
, symlinkJoin
, which
, ninja
, pybind11
, gcc11Stdenv
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
  pname = "autoawq";
  version = "0.1.5";
  format = "setuptools";

  BUILD_CUDA_EXT = "1";

  CUDA_HOME = cuda-native-redist;
  CUDA_VERSION = cudaPackages.cudaVersion;

  buildInputs = [
    pybind11
    cudaPackages.cudatoolkit
  ];

  preBuild = ''
    export PATH=${gcc11Stdenv.cc}/bin:$PATH
  '';

  nativeBuildInputs = [
    which
    ninja
  ];

  src = fetchFromGitHub {
    owner = "casper-hansen";
    repo = "AutoAWQ";
    rev = "v${version}";
    # nix-prefetch-git https://github.com/casper-hansen/AutoAWQ.git --rev refs/tags/v0.1.5
    hash = "sha256-dom4jDCK/W5GcbZfy8VSDKV5ViaafK2IEfQvuv9BJUI=";
  };

  pythonImportsCheck = [ "awq" ];

  propagatedBuildInputs = [
    torch
    tokenizers
    sentencepiece
    lm-eval
    texttable
    toml
    attributedict
    protobuf
    torchvision
    tabulate
  ];

  meta = with lib; {
    description = "AutoAWQ implements the AWQ algorithm for 4-bit quantization with a 2x speedup during inference.";
    homepage = "https://github.com/casper-hansen/AutoAWQ";
    license = licenses.mit;
    maintainers = with maintainers; [ ];
  };
}
