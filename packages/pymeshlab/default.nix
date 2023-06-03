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
, boost17x
, cgal_5
, glew
, levmar
, lib3ds
, muparser
, nexus
, python
, pkg-config
, libigl
, tinygltf
, openctm
, xercesc
, gmp
, mpfr
, u3d
}:

buildPythonPackage rec {
  pname = "PyMeshLab";
  version = "2022.2.post4";

  src = fetchFromGitHub {
    owner = "cnr-isti-vclab";
    repo = pname;
    rev = "v${version}";
    sha256 = "sha256-nyXnqZkeHNEwoGAhJSFhgUUCvRKVRtEEKRQtzSZjXz0=";
    fetchSubmodules = true;
    deepClone = true;
  };

  cmakeFlags = [
    "-DALLOW_BUNDLED_EIGEN=OFF"
    "-DALLOW_BUNDLED_GLEW=OFF"
    "-DALLOW_BUNDLED_LIB3DS=OFF"
    "-DALLOW_BUNDLED_MUPARSER=OFF"
    "-DALLOW_BUNDLED_QHULL=OFF"
    "-DALLOW_BUNDLED_OPENCTM=OFF"
    "-DALLOW_BUNDLED_BOOST=OFF"
    "-DALLOW_BUNDLED_NEWUOA=OFF"
    "-DALLOW_BUNDLED_LEVMAR=OFF"
    "-DALLOW_BUNDLED_SSYNTH=OFF"
    "-DALLOW_BUNDLED_U3D=OFF"
    # "-DSSYNTH_DIR=${structure-synth.src}"
    "-DLEVMAR_DIR=${levmar.src}"

    # "-DFETCHCONTENT_SOURCE_DIR_Teste="
  ];

  propagatedBuildInputs = [ numpy pyngrok plotly jupyterlab viser ];

  nativeBuildInputs = [ cmake qt5.wrapQtAppsHook pkg-config ];

  buildInputs = [
    gmp
    xercesc
    openctm
    pybind11
    meshlab
    tinygltf
    libigl
    lib3ds
    boost17x
    cgal_5
    libGL
    eigen
    glew
    mpfr
    muparser
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
