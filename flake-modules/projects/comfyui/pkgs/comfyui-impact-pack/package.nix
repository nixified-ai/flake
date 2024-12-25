{ comfyuiPackages,
  python3Packages,
  fetchFromGitHub
}:
let
  segment-anything = python3Packages.callPackage ../../../../packages/segment-anything {};
in
comfyuiPackages.comfyui.mkComfyUICustomNode {
  pname = "comfyui-impact-pack";
  version = "unstable-2024-09-09";
  pyproject = false;
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
    rev = "21eecb0c03223c7823cb19b318011fba3143da92";
    hash = "sha256-JJUDRQRvC9+z/UEJz5NChANQq2WsI6dzzarttGWjKxk=";
  };
}
