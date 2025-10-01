{
  comfyuiPackages,
  python3Packages,
  fetchFromGitHub,
}:
comfyuiPackages.comfyui.mkComfyUICustomNode {
  pname = "comfyui-calcuis-gguf";
  version = "unstable-2025-08-05";
  propagatedBuildInputs = with python3Packages; [
    gguf
    sentencepiece
    protobuf
  ];
  src = fetchFromGitHub {
    owner = "calcuis";
    repo = "gguf";
    rev = "b05e746ecf63d04abd8ea514c4bb3707d4655be8";
    hash = "sha256-9tyvgPbPalZ9DGt2n3n3BFsm/F/48TfP6I+75eCe4Mw=";
  };
}
