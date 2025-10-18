{
  lib,
  python3Packages,
  ...
}:
let
  clip-interrogator =
    python3Packages.callPackage ../../../../packages/clip-interrogator/default.nix
      { };
  spandrel = python3Packages.callPackage ../../../../packages/spandrel/default.nix { };
in
{
  pname = "comfyui-easy-use";

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
