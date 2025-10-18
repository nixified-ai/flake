{
  python3Packages,
}:
let
  pixeloe = python3Packages.callPackage ../../../../packages/pixeloe/default.nix { };
  colour-science = python3Packages.callPackage ../../../../packages/colour-science/default.nix { };
  transparent-background =
    python3Packages.callPackage ../../../../packages/transparent-background/default.nix
      { };
in
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
