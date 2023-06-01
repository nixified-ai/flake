{ buildPythonPackage
, fetchFromGitHub
, lib
, python
, colmap
, cmake
, ceres-solver
, boost
, freeimage
, libGL
, glew
, qt5
, torch
, hip
, cudatoolkit
, cgal
, pybind11
, tbb
, flann
, numpy
}:

let
  isRocm = torch.rocmSupport or false;

  customColmap = colmap.overrideDerivation (old: rec {
    pname = "colmap";
    version = "3.8";
    src = fetchFromGitHub {
      owner = "colmap";
      repo = "colmap";
      rev = "refs/tags/${version}";
      sha256 = "sha256-1uUbUZdz49TloEaPJijNwa51DxIPjgz/fthnbWLfgS8=";
    };

    buildInputs = old.buildInputs ++ [ flann ];
  });
in

buildPythonPackage rec {
  pname = "pycolmap";
  version = "0.4.0";
  format = "other";

  src = fetchFromGitHub {
    owner = "colmap";
    repo = pname;
    rev = "refs/tags/v${version}";
    sha256 = "sha256-W3d+uHZXkH1/QlER1HV8t1MOBOrHIXYsVeYv1zbsbW4=";
    fetchSubmodules = true;
  };

  cmakeFlags = [ "-DCOLMAP_CGAL_ENABLED=ON" ]
    ++ (if isRocm then [ ] else [ "-DCOLMAP_CUDA_ENABLED=ON"])
  ;

  buildInputs = [
    customColmap
    ceres-solver
    boost
    freeimage
    libGL
    glew
    qt5.qtbase
    cgal
    tbb
    flann
  ];
  
  propagatedBuildInputs = [ numpy ];

  nativeBuildInputs = [ cmake qt5.wrapQtAppsHook pybind11 ]
    ++ (if isRocm then [ hip ] else [ cudatoolkit ])
  ;

  installPhase = ''
    mkdir -p $out/${python.sitePackages}
    install *.so $out/${python.sitePackages}
  '';

  pythonImportsCheck = [ pname ];
}
