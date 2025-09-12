{
  comfyuiPackages,
  python3Packages,
  fetchFromGitHub,
}:
comfyuiPackages.comfyui.mkComfyUICustomNode {
  pname = "comfyui-wanmoeksampler";
  version = "unstable-2024-12-08";
  propagatedBuildInputs = with python3Packages; [
    gguf
    sentencepiece
    protobuf
  ];
  src = fetchFromGitHub {
    owner = "stduhpf";
    repo = "ComfyUI-WanMoeKSampler";
    rev = "8fc990069a69175b1f64c0dc84acbacf71682a9b";
    hash = "sha256-pCwQrP38lDPAVdw7YUz/0jD/SYxZo9aS0A54rRPSOUs=";
  };
}
