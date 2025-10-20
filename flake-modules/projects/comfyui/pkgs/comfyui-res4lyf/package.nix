{
  comfyuiPackages,
  python3Packages,
  fetchFromGitHub,
  ...
}:
comfyuiPackages.comfyui.mkComfyUICustomNode rec {
  pname = "comfyui-res4lyf";
  version = "unstable-2025-08-14";

  src = fetchFromGitHub {
    owner = "ClownsharkBatwing";
    repo = "RES4LYF";
    rev = "7750bf7800b6ad9d670308a09989fc0c04c40cec";
    hash = "sha256-ZVTXEP7TGXat+JmaJCVd/LS+F+Dx9WUo2m0FoJ4WRO0=";
  };

  patches = [ ./config.patch ];

  # pyproject = false;
  propagatedBuildInputs = with python3Packages; [
    opencv-python
    matplotlib
    scikit-image
    pywavelets
    numpy
  ];
}
