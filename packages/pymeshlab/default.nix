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
, pybind11
, jupyterlab
, viser
, cmake
, meshlab
, libGL
, qt5
, eigen
, boost
, cgal
, glew
, levmar
, lib3ds
, muparser
, nexus
, python
, pkg-config
, structure-synth
, libigl
, tinygltf
}:

buildPythonPackage rec {
  pname = "PyMeshLab";
  version = "2022.2.post4";

  src = fetchFromGitHub {
    owner = "cnr-isti-vclab";
    repo = pname;
    rev = "v${version}";
    # sha256 = "sha256-CtzyKymM/SMoiw413Y+r89R6FEHvEaBS36iDcuRkDCo=";
    sha256 = "sha256-nyXnqZkeHNEwoGAhJSFhgUUCvRKVRtEEKRQtzSZjXz0=";
    fetchSubmodules = true;
    deepClone = true;
  };

  cmakeFlags = [
  ]
    ++ meshlab.cmakeFlags
  ;

  propagatedBuildInputs = [ numpy pyngrok plotly jupyterlab viser ];

  nativeBuildInputs = [ cmake qt5.wrapQtAppsHook pkg-config ];

  buildInputs = [
    pybind11
    meshlab
    structure-synth
    tinygltf
    libigl
  ]
  ++ meshlab.buildInputs;

  pythonImportsCheck = [ "pymeshlab" "pymeshlab.pmeshlab" ];

  # TODO FIXME
  doCheck = false;

  meta = with lib; {
    description =
      "A Python interface to MeshLab";
    homepage = "https://github.com/cnr-isti-vclab/PyMeshLab";
  };
}
