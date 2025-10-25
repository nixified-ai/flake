{
  python3Packages,
}:
{
  pname = "comfyui-impact-pack";
  pyproject = false;
  dontUseNinjaBuild = true;
  propagatedBuildInputs = with python3Packages; [
    segment-anything
    scikit-image
    piexif
    transformers
    opencv4
    scipy
    numpy
    dill
    matplotlib
    sam2
  ];
  #passthru.dependencies.pkgs = with python3Packages; [
  #  gguf
  #];
}
