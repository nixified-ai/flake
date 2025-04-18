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
  version = "0.4.1";
  src-root = fetchFromGitHub {
    owner = "chaiNNer-org";
    repo = "spandrel";
    rev = "v${version}";
    hash = "sha256-saRSosJ/pXmhLX5VqK3IBwT1yo14kD4nwNw0bCT2o5w=";
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
