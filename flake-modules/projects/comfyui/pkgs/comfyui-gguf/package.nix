{
  comfyuiPackages,
  python3Packages,
  fetchFromGitHub,
}:
comfyuiPackages.comfyui.mkComfyUICustomNode {
  pname = "comfyui-gguf";
  version = "unstable-2025-09-14";
  propagatedBuildInputs = with python3Packages; [
    gguf
    sentencepiece
    protobuf
  ];
  src = fetchFromGitHub {
    owner = "city96";
    repo = "ComfyUI-GGUF";
    rev = "be2a08330d7ec232d684e50ab938870d7529471e";
    hash = "sha256-NtpoLwlcMXeVCffZmQeHKDl9hM6gCBprdnhHblrWQ20=";
  };
}
