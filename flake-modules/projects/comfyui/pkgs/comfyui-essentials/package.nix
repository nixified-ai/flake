{
  comfyuiPackages,
  python3Packages,
  fetchFromGitHub,
}:
let
  pixeloe = python3Packages.callPackage ../../../../packages/pixeloe/default.nix {};
  colour-science = python3Packages.callPackage ../../../../packages/colour-science/default.nix {};
  transparent-background = python3Packages.callPackage ../../../../packages/transparent-background/default.nix {};
in
comfyuiPackages.comfyui.mkComfyUICustomNode {
  pname = "comfyui-essentials";
  version = "unstable-2024-12-07";
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
  src = fetchFromGitHub {
    owner = "cubiq";
    repo = "ComfyUI_essentials";
    rev = "33ff89fd354d8ec3ab6affb605a79a931b445d99";
    hash = "sha256-7BaIhvHmBdUUbJaqdWAZO8lxZHWQfZJmM95wGa9xLYg=";
  };
  patches = [
    ./fix-escape-sequence-in-comment.patch
  ];
}
