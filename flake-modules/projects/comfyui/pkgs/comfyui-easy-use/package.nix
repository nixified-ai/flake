{
  lib,
  comfyuiPackages,
  fetchFromGitHub,
  python3Packages,
  ...
}:
let
  clip-interrogator =
    python3Packages.callPackage ../../../../packages/clip-interrogator/default.nix
      { };
  spandrel = python3Packages.callPackage ../../../../packages/spandrel/default.nix { };
in
comfyuiPackages.comfyui.mkComfyUICustomNode {
  pname = "comfyui-easy-use";
  version = "unstable-2025-08-17";

  src = fetchFromGitHub {
    owner = "yolain";
    repo = "ComfyUI-Easy-Use";
    rev = "1148fbe5fe0276780c56f0adfa22b96d5200d832";
    hash = "sha256-PPbCmEPE031EPL92FniP5Z7aQHBERSp3N43s5tjxUak=";
  };

  patches = [
    ./set-easy-use-path-from-env-var.patch
  ];

  patchFlags = [
    "--ignore-whitespace"
    "-p1"
  ];

  dontUseNinjaBuild = true;

  propagatedBuildInputs = with python3Packages; [
    diffusers
    accelerate
    clip-interrogator
    lark
    onnxruntime
    opencv-python
    sentencepiece
    spandrel
    matplotlib
    peft
  ];
}
