{
  comfyuiPackages,
  python3Packages,
  fetchFromGitHub,
}:
let
  color-matcher = python3Packages.callPackage ../../../../packages/color-matcher/default.nix {};
in
comfyuiPackages.comfyui.mkComfyUICustomNode {
  pname = "comfyui-kjnodes";
  version = "unstable-2025-07-27";
  pyproject = false;
  propagatedBuildInputs = with python3Packages; [
    librosa
    numpy
    pillow
    scipy
    color-matcher
    matplotlib
    huggingface-hub
  ];
  src = fetchFromGitHub {
    owner = "kijai";
    repo = "ComfyUI-KJNodes";
    rev = "a6b867b63a29ca48ddb15c589e17a9f2d8530d57";
    hash = "sha256-ZL9acyukV93OOWeIzIme6SQsU6OwhI4f9AKIol47YYo=";
  };
}
