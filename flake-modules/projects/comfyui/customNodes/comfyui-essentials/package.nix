{
  python3Packages,
}:
{
  pname = "comfyui-essentials";
  pyproject = false;
  # ninja build hook somehow activates during build
  # probably due to transitive dep
  dontUseNinjaBuild = true;
  propagatedBuildInputs = with python3Packages; [
    colour-science
    numba
    pixeloe
    rembg
    transparent-background
  ];
  patches = [
    ./fix-escape-sequence-in-comment.patch
  ];
}
