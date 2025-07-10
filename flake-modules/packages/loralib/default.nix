{
  buildPythonPackage,
  fetchPypi,
}:
buildPythonPackage rec {
  pname = "loralib";
  version = "0.1.2";
  format = "pyproject";
  src = fetchPypi {
    inherit pname version;
    hash = "sha256-Isz/SUpiVLlz3a7p+arUZXlByrQiHHXFoE4MrE+9RWc=";
  };
}
