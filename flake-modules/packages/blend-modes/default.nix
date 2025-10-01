{
  fetchPypi,
  buildPythonPackage,
  numpy,
}:
buildPythonPackage rec {
  pname = "blend_modes";
  version = "2.2.0";
  src = fetchPypi {
    inherit pname version;
    hash = "sha256-VOBwO+gwl6lK95LlKiH7vTryCmkLIckXUoPiFnYsEjo=";
  };
  format = "setuptools";

  dependencies = [
    numpy
    #sphinxcontrib-napoleon
  ];

  pythonImportsCheck = [
    "blend_modes"
  ];
}
