{
  python3Packages,
}:
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
