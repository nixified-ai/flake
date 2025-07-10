{
  fetchurl,
  comfyuiPackages,
  python3Packages,
  fetchFromGitHub,
  ...
}: let
  depth_anything_v2_vits = fetchurl {
    url = "https://huggingface.co/depth-anything/Depth-Anything-V2-Small/resolve/main/depth_anything_v2_vits.pth";
    hash = "sha256-cV+t4Tvo8in4pwzAIGb2VvJCOlnv/QV5GXu/V4YOE3g=";
  };
  depth_anything_v2_vitl = fetchurl {
    url = "https://huggingface.co/depth-anything/Depth-Anything-V2-Large/resolve/main/depth_anything_v2_vitl.pth";
    hash = "sha256-p+oZ+g7ZkkTme2JMcrhYC36VUwQyRZBb5YeWpgjrk0U=";
  };
in
  comfyuiPackages.comfyui.mkComfyUICustomNode
  rec {
    pname = "comfyui_controlnet_aux";
    version = "7c4f6fb";

    src = fetchFromGitHub {
      owner = "Fannovel16";
      repo = "comfyui_controlnet_aux";
      rev = "7c4f6fb6ff18aa6dbfd4f77c2e8ad46119b5d84d";
      hash = "sha256-iU1qkhV4DTlsSuL2tFovnkiDSIVeVCISPtwPnnz6pOM=";
    };

    pyproject = false;
    propagatedBuildInputs = with python3Packages; [
      opencv-python
      matplotlib
      scikit-image
    ];

    postInstall = ''
      mkdir -p $out/${python3Packages.python.sitePackages}/custom_nodes/${pname}/ckpts/depth-anything/Depth-Anything-V2-Small
      ln -fs  ${depth_anything_v2_vits} $out/${python3Packages.python.sitePackages}/custom_nodes/${pname}/ckpts/depth-anything/Depth-Anything-V2-Small/depth_anything_v2_vits.pth

      mkdir -p $out/${python3Packages.python.sitePackages}/custom_nodes/${pname}/ckpts/depth-anything/Depth-Anything-V2-Large
      ln -fs ${depth_anything_v2_vitl} $out/${python3Packages.python.sitePackages}/custom_nodes/${pname}/ckpts/depth-anything/Depth-Anything-V2-Large/depth_anything_v2_vitl.pth
    '';

    # propagatedBuildInputs = with pkgs.python3Packages; [
    #   torch
    #   #importlib_metadata
    #   #huggingface_hub
    #   scipy
    #   opencv-python
    #   filelock
    #   numpy
    #   #Pillow
    #   einops
    #   torchvision
    #   pyyaml
    #   scikit-image
    #   python-dateutil
    #   #mediapipe
    #   svglib
    #   fvcore
    #   yapf
    #   omegaconf
    #   ftfy
    #   addict
    #   yacs
    #   trimesh #[easy]
    #   albumentations
    #   scikit-learn
    #   matplotlib
    # ];
  }
