{
  python3Packages,
}:
let
  color-matcher = python3Packages.callPackage ../../../../packages/color-matcher/default.nix { };
in
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
