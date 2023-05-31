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
, makeWrapper
, accelerate
# , nvidia-thrust
, numpy
, absl-py
, gin-config
, wheel
, matplotlib
, trimesh
, opencv3
, scipy
, scikitimage
, ninja
, rawpy
, addOpenGLRunpath
, pillow
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

    buildInputs = []
    ++ (if isRocm
      then [
        hipsparse
        rocblas
        rocblas-header
        rocthrust
      ]
      else [
        cudaPackages.cudatoolkit
      ]);

    nativeBuildInputs = [ which ninja addOpenGLRunpath ]
    ++ (if isRocm
      then [ hip ]
      else [ cudaPackages.cudatoolkit ]);

    postFixup= ''
      # addOpenGLRunpath $out/${python.sitePackages}/*.so
    '';

    pythonImportsCheck = [ "_gridencoder" ];

  }).overrideDerivation (old: {
    stdenv = if isRocm then stdenv else  gcc11Stdenv;
  });

  ourScikitImage = scikitimage.overrideAttrs (old: {
    prePatch = (old.prePatch or "") + ''
      echo resolvendo buxa
      substituteInPlace skimage/color/colorconv.py \
        --replace 'from scipy import linalg' 'from numpy import linalg'
    '';
  });

in

buildPythonPackage rec {
  pname = "zipnerf_pytorch";
  inherit version;

  format = "other";

  inherit src;

  PYTHONFAULTHANDLER=1;
  DEBUG=1;
  OPENBLAS_CORETYPE="haswell";

  prePatch = ''
    substituteInPlace internal/configs.py \
      --replace "gin.add_config_file_search_path('configs/')" "gin.add_config_file_search_path('$out/$_INSTALL_PATH/configs/')"
    substituteInPlace $(find -type f | grep .py) \
      --replace 'from internal' 'from zipnerf_pytorch.internal'
  '';

  nativeBuildInputs = [ python.pkgs.wrapPython makeWrapper which ];

  propagatedBuildInputs = [
    gridencoder
    # accelerate
    gin-config
    opencv3
    pillow
    matplotlib
    # scipy
    ourScikitImage
    absl-py
    torch
    rawpy
  ];

  pythonPath = propagatedBuildInputs;

  # the second import is to check if something is conflicting with scikit
  pythonImportsCheck = [ pname "${pname}.internal.datasets" ];

  installPhase = ''
    export INSTALL_DIR=$out/$_INSTALL_PATH
    mkdir -p $out/${python.sitePackages}/$pname
    cp -r * $out/${python.sitePackages}/$pname

    touch $out/${python.sitePackages}/$pname

    mkdir -p $out/bin
  '';

  preFixup = ''
    buildPythonPath "$out $pythonPath"
    for bin in eval extract render train; do
      makeWrapper ${python.interpreter} $out/bin/zipnerf_$bin \
        --prefix PYTHONPATH : "$program_PYTHONPATH" \
        --prefix PATH : "$program_PATH" \
        --add-flags $out/${python.sitePackages}/$pname/$bin.py
    done
  '';

}
