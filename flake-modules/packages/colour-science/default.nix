{
  buildPythonPackage,
  fetchFromGitHub,
  imageio,
  numpy,
  poetry-core,
  scipy,
  typing-extensions,
}: let
  version = "0.4.4";
in
  buildPythonPackage rec {
    pname = "colour-science";
    inherit version;
    pyproject = true;
    src = fetchFromGitHub {
      owner = "colour-science";
      repo = "colour";
      rev = "v${version}";
      sha256 = "sha256-o+hSC64vMR41PCXYbi5p/G9jhQZ1+zCINNeCfrhQKrg=";
    };
    nativeBuildInputs = [
      imageio
      numpy
      poetry-core
      scipy
      typing-extensions
    ];

    pythonImportsCheck = ["colour"];
  }
