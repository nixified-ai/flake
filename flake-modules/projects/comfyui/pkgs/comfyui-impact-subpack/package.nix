{
  comfyuiPackages,
  python3Packages,
  fetchFromGitHub,
}:
let
  ultralytics = python3Packages.callPackage ../../../../packages/ultralytics { };
in
comfyuiPackages.comfyui.mkComfyUICustomNode {
  pname = "comfyui-impact-subpack";
  version = "unstable-2025-07-22";
  pyproject = false;
  dontUseNinjaBuild = true;
  propagatedBuildInputs = with python3Packages; [
    ultralytics
    opencv-python-headless
    numpy
    dill
    matplotlib
  ];
  src = fetchFromGitHub {
    owner = "ltdrdata";
    repo = "ComfyUI-Impact-Subpack";
    rev = "50c7b71a6a224734cc9b21963c6d1926816a97f1";
    hash = "sha256-+qYmGdHjrWYfJ+uqGURWk1y8kVR0pBc+ObjUyM0A7UA=";
  };
}
