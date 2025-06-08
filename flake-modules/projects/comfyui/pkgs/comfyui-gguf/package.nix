{ comfyuiPackages
, python3Packages
, fetchFromGitHub
}:
comfyuiPackages.comfyui.mkComfyUICustomNode {
  pname = "comfyui-gguf";
  version = "unstable-2025-05-09";
  pyproject = true;

  propagatedBuildInputs = with python3Packages; [
    gguf
  ];

  dependencies = with python3Packages; [
    sentencepiece
    protobuf
    torch
  ];

  src = fetchFromGitHub {
    owner = "city96";
    repo = "ComfyUI-GGUF";
    rev = "a2b75978fd50c0227a58316619b79d525b88e570";
    hash = "sha256-nsAnkzapDWUFtuNnroHqcX4PR5fUWkXXIH+zn5K3aqo=";
  };
}
