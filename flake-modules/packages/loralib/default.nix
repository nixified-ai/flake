{
  lib,
  buildPythonPackage,
  fetchPypi,
  setuptools,
  wheel,
  torch,
}:

buildPythonPackage rec {
  pname = "loralib";
  version = "0.1.2";
  pyproject = true;

  src = fetchPypi {
    inherit pname version;
    hash = "sha256-Isz/SUpiVLlz3a7p+arUZXlByrQiHHXFoE4MrE+9RWc=";
  };

  build-system = [
    setuptools
    wheel
  ];

  pythonImportsCheck = [
    "loralib"
  ];

  propagatedBuildInputs = [
    torch
  ];

  meta = {
    description = "PyTorch implementation of low-rank adaptation (LoRA), a parameter-efficient approach to adapt a large pre-trained deep learning model which obtains performance on-par with full fine-tuning";
    homepage = "http://pypi.org/project/loralib";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ ];
  };
}
