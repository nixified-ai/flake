{ buildPythonPackage
, fetchFromGitHub
, lib
, python
, torch
, cudaPackages
, which
, hip
, hipsparse
, rocblas
, rocthrust
, runCommand
, gcc11Stdenv
, stdenv
, wrapPython
, makeWrapper
, accelerate
# , nvidia-thrust
}:

let
  isRocm = torch.rocmSupport or false;

  version = "2023.05.28-unstable";

  src = fetchFromGitHub {
    owner = "SuLvXiangXin";
    repo = "zipnerf-pytorch";
    rev = "20866db84b31addc9d7fb2aa57e2b50fd33ce15b";
    sha256 = "sha256-IglTczgFqnpWw/Ck36G308yFpgHL3YOSt7o1lwkwJFE=";
  };

  rocblas-header = runCommand "rocblas-header" {} ''
    mkdir $out
    ln -s ${rocblas}/include/rocblas $out/include
  '';

  gridencoder = (buildPythonPackage {
    pname = "gridencoder";
    inherit version;

    src = "${src}/gridencoder";

    propagatedBuildInputs = [ torch ];

    TORCH_CUDA_ARCH_LIST = "7.0+PTX";

    buildInputs = [ ]
    ++ (if isRocm
      then [
        hipsparse
        rocblas
        rocblas-header
        rocthrust
      ]
      else [ cudaPackages.cudatoolkit ]);

    nativeBuildInputs = [ which ]
    ++ (if isRocm
      then [ hip ]
      else [ cudaPackages.cuda_nvcc ]);

  }).overrideDerivation (old: {
    stdenv = if isRocm then stdenv else  gcc11Stdenv;
  });

in

buildPythonPackage {
  pname = "zipnerf";
  inherit version;

  format = "other";

  inherit src;

  buildInputs = [ gridencoder ];

  nativeBuildInputs = [ wrapPython makeWrapper which ];

  wrappedPython = (python.withPackages (p: with p; [
    numpy
    absl-py
    accelerate
    gin-config
    matplotlib
    trimesh
    opencv3
    scipy
    scikitimage
  ])).interpreter;

  installPhase = ''
    export INSTALL_DIR=$out/${python.sitePackages}/zipnerf-pytorch
    mkdir -p $INSTALL_DIR
    cp -r * $INSTALL_DIR

    mkdir -p $out/bin

    for bin in eval extract render train; do
      makeWrapper $wrappedPython $out/bin/zipnerf-$bin \
        --prefix PYTHONPATH : $INSTALL_DIR \
        --add-flags $INSTALL_DIR/$bin.py
    done
  '';
}
