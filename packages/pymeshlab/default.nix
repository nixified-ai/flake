# WARNING: This file was automatically generated. You should avoid editing it.
# If you run pynixify again, the file will be either overwritten or
# deleted, and you will lose the changes you made to it.

{ buildPythonPackage
, lib
, fetchPypi
, fetchFromGitHub
, numpy
, pyngrok
, plotly
, jupyterlab
, viser
, cmake
, meshlab
, libGL
, qt5
, eigen
, boost
, cgal
, levmar
, lib3ds
, muparser
, nexus
}:

buildPythonPackage rec {
  pname = "PyMeshLab";
  version = "2022.2.post4";

  src = fetchFromGitHub {
    owner = "cnr-isti-vclab";
    repo = pname;
    rev = "v${version}";
    fetchSubmodules = true;
    sha256 = "sha256-CtzyKymM/SMoiw413Y+r89R6FEHvEaBS36iDcuRkDCo=";
  };

  propagatedBuildInputs = [ numpy pyngrok plotly jupyterlab viser ];

  nativeBuildInputs = [ cmake qt5.wrapQtAppsHook ];

  buildInputs = [
    meshlab
    libGL
    qt5.qtbase
    eigen
    boost
    cgal
    levmar
    lib3ds
    muparser
    nexus
  ];

  pythonImportsCheck = [ "pymeshlab" "pymeshlab.pmeshlab" ];

  # TODO FIXME
  doCheck = false;

  meta = with lib; {
    description =
      "A Python interface to MeshLab";
    homepage = "https://github.com/cnr-isti-vclab/PyMeshLab";
  };
}
