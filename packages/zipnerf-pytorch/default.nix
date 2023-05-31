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
, numpy
, absl-py
, gin-config
, matplotlib
, trimesh
, opencv3
, scipy
, scikitimage
, ninja
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

    nativeBuildInputs = [ which ninja ]
    ++ (if isRocm
      then [ hip ]
      else [ cudaPackages.cuda_nvcc ]);

    postInstall = ''
      ls -R $out
    '';

    pythonImportsCheck = [ "_gridencoder" ];

  }).overrideDerivation (old: {
    stdenv = if isRocm then stdenv else  gcc11Stdenv;
  });

in

buildPythonPackage rec {
  pname = "zipnerf_pytorch";
  inherit version;

  format = "other";

  inherit src;

  _INSTALL_PATH = "${python.sitePackages}/zipnerf_pytorch";

  prePatch = ''
    substituteInPlace internal/configs.py \
      --replace "gin.add_config_file_search_path('configs/')" "gin.add_config_file_search_path('$out/$_INSTALL_PATH/configs/')"
    substituteInPlace $(find -type f | grep .py) \
      --replace 'from internal' 'from zipnerf_pytorch.internal'
  '';

  buildInputs = [
    gridencoder
  ];

  nativeBuildInputs = [ wrapPython makeWrapper which ];

  propagatedBuildInputs = [
    numpy
    absl-py
    accelerate
    gin-config
    matplotlib
    trimesh
    opencv3
    scipy
    scikitimage
  ];

  pythonImportsCheck = [ pname ];

  installPhase = ''
    export INSTALL_DIR=$out/$_INSTALL_PATH
    mkdir -p $INSTALL_DIR
    cp -r * $INSTALL_DIR

    buildPythonPath
    echo pythonpath
    echo $program_PYTHONPATH

    touch $INSTALL_DIR/__init__.py

    mkdir -p $out/bin

    for bin in eval extract render train; do
      makeWrapper ${(python.withPackages (p: propagatedBuildInputs)).interpreter} $out/bin/zipnerf_$bin \
        --prefix PYTHONPATH : $out/${python.sitePackages} \
        --add-flags $INSTALL_DIR/$bin.py \
        --prefix PYTHONPATH : "$program_PYTHONPATH" \
        --prefix PATH : "$program_PATH"
    done
  '';
}
