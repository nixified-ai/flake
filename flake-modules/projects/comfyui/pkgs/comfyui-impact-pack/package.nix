{
  comfyuiPackages,
  python3Packages,
  fetchFromGitHub,
}:
let
  segment-anything = python3Packages.callPackage ../../../../packages/segment-anything { };
in
comfyuiPackages.comfyui.mkComfyUICustomNode {
  pname = "comfyui-impact-pack";
  version = "unstable-2025-09-25";
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
  src = fetchFromGitHub {
    owner = "ltdrdata";
    repo = "ComfyUI-Impact-Pack";
    rev = "cb0655f9a11ad771b4f6a846f08be29b5b66f0eb";
    hash = "sha256-Sxbr0v3Mc/odBW0Io5KJX/y29prEKpfI9O9zvPzRyvk=";
  };
}
