{
  python3Packages,
}:
let
  segment-anything = python3Packages.callPackage ../../../../packages/segment-anything { };
in
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
  ];
  #passthru.dependencies.pkgs = with python3Packages; [
  #  gguf
  #];
}
