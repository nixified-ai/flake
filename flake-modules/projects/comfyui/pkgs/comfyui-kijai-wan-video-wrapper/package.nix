{
  comfyuiPackages,
  python3Packages,
  fetchFromGitHub,
  gccStdenv,
}:
let
  pyloudnorm = python3Packages.callPackage ../../../../packages/pyloudnorm/default.nix { };
  sageattention = python3Packages.callPackage ../../../../packages/sageattention/default.nix { };
in
comfyuiPackages.comfyui.mkComfyUICustomNode {
  pname = "comfyui-kijai-wan-video-wrapper";
  version = "unstable-2025-07-31";
  pyproject = false;
  propagatedBuildInputs = with python3Packages; [
    ftfy
    accelerate
    einops
    diffusers
    peft
    sentencepiece
    protobuf
    pyloudnorm
    gguf
    sageattention
    gccStdenv.cc
  ];
  src = fetchFromGitHub {
    owner = "kijai";
    repo = "ComfyUI-WanVideoWrapper";
    rev = "ee1e762a7ff71a743157fba1a4be092d111a65fb";
    hash = "sha256-PZF6Gt2qEs3GTLVp2DPd7NQzx6wA1rbezJaClz4iuLU=";
  };
  dontUseNinjaBuild = true;
}
