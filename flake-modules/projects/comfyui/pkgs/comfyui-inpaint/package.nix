{
  comfyuiPackages,
  fetchFromGitHub,
  ...
}:
comfyuiPackages.comfyui.mkComfyUICustomNode {
  pname = "comfyui-inpaint-nodes";
  version = "726e16f";

  src = fetchFromGitHub {
    owner = "Acly";
    repo = "comfyui-inpaint-nodes";
    rev = "726e16ff2742be285b3da78b73333ba6227ad234";
    hash = "sha256-r1q8U4V3nH2P1tlinOujeYvqceFa4uriVfHDoDathog=";
  };
}
