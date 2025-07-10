{
  fetchPypi,
  buildPythonPackage,
}:
buildPythonPackage rec {
  pname = "blend_modes";
  version = "2.2.0";
  format = "pyproject";
  src = fetchPypi {
    inherit pname version;
    hash = "sha256-VOBwO+gwl6lK95LlKiH7vTryCmkLIckXUoPiFnYsEjo=";
  };
}
