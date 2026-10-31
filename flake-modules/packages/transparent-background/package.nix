{
  buildPythonPackage,
  fetchPypi,
  setuptools,
  torch,
  torchvision,
  opencv-python,
  timm,
  tqdm,
  kornia,
  gdown,
  wget,
  easydict,
  pyyaml,
  albumentationsx,
  albucore,
  pymatting,
}:
buildPythonPackage rec {
  pname = "transparent_background";
  version = "1.3.4";
  format = "pyproject";
  src = fetchPypi {
    inherit pname version;
    hash = "sha256-KAFOzgrlt3YPfBIjGEDbP1rRtJOWjQ19vOSgeeIG36Y=";
  };

  preBuild = ''
    export HOME=$(mktemp -d)
  '';

  buildInputs = [ setuptools ];

  pythonRemoveDeps = [ "albumentations" ];

  propagatedBuildInputs = [
    torch
    torchvision
    opencv-python
    timm
    tqdm
    kornia
    gdown
    wget
    easydict
    pyyaml
    albumentationsx
    albucore
    pymatting
  ];
}
