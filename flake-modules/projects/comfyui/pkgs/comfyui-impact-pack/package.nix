{ comfyuiPackages
, python3Packages
, fetchFromGitHub
}:
let
  segment-anything = python3Packages.callPackage ../../../../packages/segment-anything { };
in
comfyuiPackages.comfyui.mkComfyUICustomNode rec {
  pname = "comfyui-impact-pack";
  version = "8.15.3";
  pyproject = false;

  dependencies = with python3Packages; [
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

  # passthru.dependencies.pkgs = with python3Packages; [
  #  gguf
  # ];

  src = fetchFromGitHub {
    owner = "ltdrdata";
    repo = "ComfyUI-Impact-Pack";
    rev = version;
    hash = "sha256-nhfgs/XqT3Ziwz24Ke+atfCSmq6TuU/91ufcmWO1w+Q=";
  };
}
