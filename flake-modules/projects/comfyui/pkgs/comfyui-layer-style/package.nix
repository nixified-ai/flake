{
  comfyuiPackages,
  fetchFromGitHub,
  python3Packages,
}: let
  colour-science = python3Packages.callPackage ../../../../packages/colour-science/default.nix {};
  blend-modes = python3Packages.callPackage ../../../../packages/blend-modes/default.nix {};
in
  comfyuiPackages.comfyui.mkComfyUICustomNode
  {
    pname = "comfyui-layer-style";
    version = "a46b1e6";

    dontBuild = true;

    src = fetchFromGitHub {
      owner = "chflame163";
      repo = "ComfyUI_LayerStyle";
      rev = "a46b1e6d26d45be9784c49f7065ba44700ef2b63";
      hash = "sha256-DM0OYw2QQ4z9Oc2aUTjAsGeNfM1jExuQluHZ/Gk5XO0=";
    };

    propagatedBuildInputs = with python3Packages; [
      numpy
      pillow
      torch
      matplotlib
      scipy
      scikit-image
      scikit-learn
      opencv4 #opencv-contrib-python
      pymatting
      timm
      colour-science
      blend-modes
      transformers
      huggingface-hub
      loguru
    ];
  }
