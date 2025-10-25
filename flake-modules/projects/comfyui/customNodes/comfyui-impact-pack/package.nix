{
  python3Packages,
}:
let
  segment-anything = python3Packages.callPackage ../../../../packages/segment-anything { };
  sam2 = python3Packages.callPackage ../../../../packages/sam2 { };
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
    sam2
  ];
  #passthru.dependencies.pkgs = with python3Packages; [
  #  gguf
  #];
}
