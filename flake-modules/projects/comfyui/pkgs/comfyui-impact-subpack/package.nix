{
  python3Packages,
}:
let
  ultralytics = python3Packages.callPackage ../../../../packages/ultralytics { };
in
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
