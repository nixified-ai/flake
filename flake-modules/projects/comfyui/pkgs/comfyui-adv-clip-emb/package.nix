{ comfyuiPackages,
  python3Packages,
  fetchFromGitHub
}:
comfyuiPackages.comfyui.mkComfyUICustomNode {
  pname = "comfyui-adv-clip-emb";
  version = "unstable-2024-04-09";
  propagatedBuildInputs = with python3Packages; [
    gguf
    sentencepiece
    protobuf
  ];
  src = fetchFromGitHub {
    owner = "BlenderNeko";
    repo = "ComfyUI_ADV_CLIP_emb";
    rev = "63984deefb005da1ba90a1175e21d91040da38ab";
    hash = "sha256-9oDBE4M473RW0MBRewHOqiy6TQu1uSIAMQ8vBBkQ+Rs=";
  };
}
