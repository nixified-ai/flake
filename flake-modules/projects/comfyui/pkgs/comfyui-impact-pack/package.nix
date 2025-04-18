{ comfyuiPackages
, python3Packages
, fetchFromGitHub
}:
let
  segment-anything = python3Packages.callPackage ../../../../packages/segment-anything { };
in
comfyuiPackages.comfyui.mkComfyUICustomNode rec {
  pname = "comfyui-impact-pack";
  version = "8.11";
  pyproject = false;

  dependencies = with python3Packages; [
    segment-anything
    scikit-image
    piexif
    transformers
    opencv4
    scipy
    numpy_1
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
    hash = "sha256-fQazzEA+7M/CtmKDKsPW3XfuCyLs4ui8msoJUeauE/Q=";
  };
}
