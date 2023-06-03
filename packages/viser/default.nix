{ buildPythonPackage
, lib
, fetchPypi
, poetry-core
, tyro
, gdown
, rich
, numpy
, liblzfse
, websockets
, msgpack
, scipy
, scikit-image
, pythonRelaxDepsHook
}:

buildPythonPackage rec {
  pname = "viser";
  version = "0.0.13";

  format = "pyproject";

  src = fetchPypi {
    inherit pname version;
    sha256 = "sha256-PTrr4CjtuD/XyaEp4xhUaZ5u8Ap1Jbkzk5jZ5MdjW7o=";
  };

  nativeBuildInputs = [ poetry-core pythonRelaxDepsHook ];

  pythonRelaxDeps = [ "gdown" "rich" ];
  pythonRemoveDeps = [ "pre-commit" ];

  propagatedBuildInputs = [ tyro gdown rich numpy liblzfse websockets msgpack scipy scikit-image ];
}
