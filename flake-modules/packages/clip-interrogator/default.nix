{
  buildPythonPackage,
  fetchPypi,
  python3Packages,
  setuptools,
  torch,
  torchvision,
  pillow,
  requests,
  safetensors,
  tqdm,
  open-clip-torch,
  accelerate,
  transformers,
}:
buildPythonPackage rec {
  pname = "clip-interrogator";
  version = "0.6.0";
  format = "pyproject";

  src = fetchPypi {
    inherit pname version;
    hash = "sha256-55Qjcv6blhgYgfcIPjF53nRuWbDjxBmfs+Phm+9CFpM=";
  };

  build-system = [
    setuptools
  ];

  dontUseNinjaBuild = true;

  propagatedBuildInputs = [
    torch
    torchvision
    pillow
    requests
    safetensors
    tqdm
    open-clip-torch
    accelerate
    transformers
  ];
}
