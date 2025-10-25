{
  python3Packages,
}:
{
  pname = "comfyui-kjnodes";
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
}
