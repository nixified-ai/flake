{
  buildPythonPackage,
  fetchPypi,
}:
buildPythonPackage rec {
  pname = "pilgram";
  version = "1.2.1";
  format = "setuptools";

  src = fetchPypi {
    inherit pname version;
    hash = "sha256-omnrGJmVivuqVBY6J3nSlvtPyGdNmU+77t4+Qiu8k4c=";
  };
}
