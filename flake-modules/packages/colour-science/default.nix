{
  buildPythonPackage,
  fetchFromGitHub,
  hatchling,
  imageio,
  numpy,
  poetry-core,
  scipy,
  typing-extensions,
}:
let
  version = "0.4.6";
in
buildPythonPackage rec {
  pname = "colour-science";
  inherit version;
  pyproject = true;
  src = fetchFromGitHub {
    owner = "colour-science";
    repo = "colour";
    rev = "v${version}";
    sha256 = "sha256-kjJc6D4jhvAJh6rIVvKO2bw++K3XlfjD4Djav6778lk=";
  };
  nativeBuildInputs = [
    hatchling
    imageio
    numpy
    poetry-core
    scipy
    typing-extensions
  ];

  pythonImportsCheck = [ "colour" ];
}
