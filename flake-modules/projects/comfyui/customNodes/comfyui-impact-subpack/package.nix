{
  python3Packages,
}:
{
  pname = "comfyui-impact-subpack";
  pyproject = false;
  dontUseNinjaBuild = true;
  propagatedBuildInputs = with python3Packages; [
    ultralytics
    opencv-python-headless
    numpy
    dill
    matplotlib
  ];
}
