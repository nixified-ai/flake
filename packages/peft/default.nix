{ lib
, buildPythonPackage
, fetchFromGitHub
, accelerate
, setuptools
, packaging
, numpy
, transformers
}:

buildPythonPackage rec {
  pname = "peft";
  version = "0.2.0";
  format = "pyproject";

  src = fetchFromGitHub {
    owner = "huggingface";
    repo = "peft";
    rev = "v${version}";
    hash = "sha256-NPpY29HMQe5KT0JdlLAXY9MVycDslbP2i38NSTirB3I=";
  };

  pythonImportsCheck = [ "peft" ];

  nativeBuildInputs = [ setuptools packaging ];

  propagatedBuildInputs = [ numpy accelerate transformers ];
}
