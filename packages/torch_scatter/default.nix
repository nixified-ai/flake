{ buildPythonPackage
, fetchFromGitHub
, lib
, torch
, which
, pytest
, pytest-cov
}:

buildPythonPackage rec {
  pname = "torch_scatter";
  version = "2.1.1";

  src = fetchFromGitHub {
    owner = "rusty1s";
    repo = "pytorch_scatter";
    rev = version;
    sha256 = "sha256-oAxWTX412dWFb2DYo9UbN+N1BUvg4nB/JL1cMoJIkjw=";
  };

  nativeBuildInputs = [ which pytest pytest-cov ];

  propagatedBuildInputs = [ torch ];

  setuptoolsCheckPhase = "pytest";

  pythonImportsCheck = [ pname ];
}
