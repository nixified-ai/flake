{
  python3Packages,
}:
let
  colour-science = python3Packages.callPackage ../../../../packages/colour-science/default.nix { };
  blend-modes = python3Packages.callPackage ../../../../packages/blend-modes/default.nix { };
in
{
  pname = "comfyui-layer-style";

  dontBuild = true;

  propagatedBuildInputs = with python3Packages; [
    numpy
    pillow
    torch
    matplotlib
    scipy
    scikit-image
    scikit-learn
    opencv4 # opencv-contrib-python
    pymatting
    timm
    colour-science
    blend-modes
    transformers
    huggingface-hub
    loguru
  ];
}
