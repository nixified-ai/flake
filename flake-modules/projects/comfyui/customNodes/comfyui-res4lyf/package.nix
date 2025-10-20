{
  python3Packages,
  ...
}:
{
  pname = "comfyui-res4lyf";

  # pyproject = false;
  propagatedBuildInputs = with python3Packages; [
    opencv-python
    matplotlib
    scikit-image
    pywavelets
    numpy
  ];

  patches = [ ./config.patch ];
}
