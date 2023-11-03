# WARNING: This file was automatically generated. You should avoid editing it.
# If you run pynixify again, the file will be either overwritten or
# deleted, and you will lose the changes you made to it.

{ buildPythonPackage, codecov, colour-runner, coverage, deepdiff, fetchPypi
, inspecta, lib, rootpath, setuptools-git, tox }:

buildPythonPackage rec {
  pname = "attributedict";
  version = "0.3.0";

  src = fetchPypi {
    inherit pname version;
    sha256 = "0yhwg6p8wwnlq5g6qimwwz5v3m7afpczf8ndlf2pg0d15jsklg4q";
  };

  buildInputs = [ setuptools-git ];
  propagatedBuildInputs =
    [ rootpath inspecta colour-runner deepdiff tox coverage codecov ];

  # TODO FIXME
  doCheck = false;

  meta = with lib; {
    description = "A dictionary object with attributes support.";
    homepage = "https://github.com/grimen/python-attributedict";
  };
}
