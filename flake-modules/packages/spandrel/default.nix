{
  buildPythonPackage,
  fetchFromGitHub,
  setuptools,
  torch,
  torchvision,
  safetensors,
  numpy,
  einops,
  typing-extensions,
}: let
  version = "0.3.4";
  src-root = fetchFromGitHub {
    owner = "chaiNNer-org";
    repo = "spandrel";
    rev = "v${version}";
    sha256 = "sha256-cwY8gFcaHkyYI0y31WK76FKeq0jhYdbArHhh8Q6c3DE=";
  };
in
  buildPythonPackage {
    pname = "spandrel";
    inherit version;
    src = "${src-root}/libs/spandrel";
    pyproject = true;
    buildInputs = [
      torch
      torchvision
      safetensors
      numpy
      einops
      typing-extensions
    ];
    propagatedBuildInputs = [
      setuptools
    ];

    doCheck = false;
  }
