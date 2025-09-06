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
  version = "unstable-2025-03-23";
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
    rev = "0b1ac0f1c5a395e17065821e4fd47aba3bf23900";
    hash = "sha256-GoRtQus50OsAD57rH7tCwAaIkM/wJaBx75/5aVnCFOo=";
  };
}
