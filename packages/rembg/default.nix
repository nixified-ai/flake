{
  buildPythonPackage,
  fetchFromGitHub,
  pythonRelaxDepsHook,
  jsonschema,
  numpy,
  onnxruntime,
  opencv4,
  pillow,
  pooch,
  pymatting,
  scikit-image,
  scipy,
  tqdm,
}: let
  version = "2.0.57";
in
  buildPythonPackage {
    pname = "rembg";
    inherit version;
    src = fetchFromGitHub {
      owner = "danielgatis";
      repo = "rembg";
      rev = "v${version}";
      sha256 = "sha256-71A46escxE8sType/3XSE8plHXNA7tKJ/Ltb0BwNcrs=";
    };
    pyproject = true;
    nativeBuildInputs = [
      jsonschema
      numpy
      onnxruntime
      opencv4
      pillow
      pooch
      pymatting
      scikit-image
      scipy
      tqdm
      pythonRelaxDepsHook
    ];
    pythonRemoveDeps = ["opencv-python-headless"];
  }
