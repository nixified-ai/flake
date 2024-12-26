{
  lib,
  buildPythonPackage,
  fetchFromGitHub,
  setuptools,
  wheel,
  jupyter,
  matplotlib,
  numpy,
  opencv-python,
  scikit-image,
  scipy,
  torch,
  torchvision,
  tqdm,
  pythonRelaxDepsHook,
}:

buildPythonPackage rec {
  pname = "perceptual-similarity";
  version = "0.1.4";
  pyproject = true;

  src = fetchFromGitHub {
    owner = "richzhang";
    repo = "PerceptualSimilarity";
    rev = "v${version}";
    hash = "sha256-dIQ9B/HV/2kUnXLXNxAZKHmv/Xv37kl2n6+8IfwIALE=";
  };

  build-system = [
    setuptools
    wheel
  ];

  nativeBuildInputs = [
    pythonRelaxDepsHook
  ];

  pythonRelaxDeps = [ "torchvision" ];

  dependencies = [
    jupyter
    matplotlib
    numpy
    opencv-python
    scikit-image
    scipy
    torch
    torchvision
    tqdm
  ];

  pythonImportsCheck = [
    "lpips"
  ];

  meta = {
    description = "LPIPS metric. pip install lpips";
    homepage = "https://github.com/richzhang/PerceptualSimilarity";
    license = lib.licenses.bsd2;
    maintainers = with lib.maintainers; [ ];
  };
}

