{ comfyuiPackages
, python3Packages
, fetchFromGitHub
}:
comfyuiPackages.comfyui.mkComfyUICustomNode {
  pname = "comfyui-gguf";
  version = "unstable-2025-04-16";
  pyproject = false;

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
    rev = "e29f526c6826f06166d1ad81910b60d28b19cf8b";
    hash = "sha256-fQazzEA+7M/CtmKDKsPW3XfuCyLs4ui8msoJUeauE/Q=";
  };
}
