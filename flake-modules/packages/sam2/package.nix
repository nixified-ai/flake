{
  lib,
  buildPythonPackage,
  fetchPypi,
  setuptools,
  torch,
  torchvision,
  numpy,
  tqdm,
  hydra-core,
  iopath,
  pillow,
}:

buildPythonPackage rec {
  pname = "sam2";
  version = "1.1.0";
  pyproject = true;

  src = fetchPypi {
    inherit pname version;
    hash = "sha256-fg6iUtQ8ENhT46z84LV3CsaDwwSBvW3jETAOnUT0W3Q=";
  };

  build-system = [
    setuptools
    torch
  ];

  pythonImportsCheck = [
    "sam2"
  ];

  propagatedBuildInputs = [
    torch
    torchvision
    numpy
    tqdm
    hydra-core
    iopath
    pillow
  ];

  meta = {
    description = "SAM 2: Segment Anything in Images and Videos";
    homepage = "http://pypi.org/project/sam2";
    license = with lib.licenses; [
      bsd3
      asl20
    ];
    maintainers = with lib.maintainers; [ ];
  };
}
