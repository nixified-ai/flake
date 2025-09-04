{
  buildPythonPackage,
  fetchPypi,
}:
buildPythonPackage rec {
  pname = "clip-interrogator";
  version = "0.6.0";
  format = "pyproject";
  src = fetchPypi {
    inherit pname version;
    hash = "sha256-55Qjcv6blhgYgfcIPjF53nRuWbDjxBmfs+Phm+9CFpM=";
  };
}
