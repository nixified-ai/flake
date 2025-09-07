{
  comfyuiPackages,
  python3Packages,
  fetchFromGitHub,
}:
comfyuiPackages.comfyui.mkComfyUICustomNode {
  pname = "comfyui-gguf";
  version = "unstable-2025-06-15";
  propagatedBuildInputs = with python3Packages; [
    gguf
    sentencepiece
    protobuf
  ];
  src = fetchFromGitHub {
    owner = "city96";
    repo = "ComfyUI-GGUF";
    rev = "b3ec875a68d94b758914fd48d30571d953bb7a54";
    hash = "sha256-DdCZnRtx9svz9aNxS+HJORNYsDoWVI9DWLcMocRT268=";
  };
}
