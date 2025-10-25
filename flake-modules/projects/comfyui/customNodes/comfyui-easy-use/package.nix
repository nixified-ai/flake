{
  lib,
  python3Packages,
  ...
}:
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
