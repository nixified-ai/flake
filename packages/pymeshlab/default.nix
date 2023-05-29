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
}:

buildPythonPackage rec {
  pname = "PyMeshLab";
  version = "2022.2.post4";

  src = fetchFromGitHub {
    owner = "cnr-isti-vclab";
    repo = pname;
    rev = "v${version}";
    sha256 = "sha256-NmnEp0ThF/YLhuVmjWsscP5l6V8TIrn2I47qC/owQCo=";
  };

  propagatedBuildInputs = [ numpy pyngrok plotly jupyterlab viser ];

  # TODO FIXME
  doCheck = false;

  meta = with lib; {
    description =
      "A Python interface to MeshLab";
    homepage = "https://github.com/cnr-isti-vclab/PyMeshLab";
  };
}
