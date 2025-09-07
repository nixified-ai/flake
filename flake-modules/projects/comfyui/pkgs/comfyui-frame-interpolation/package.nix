{
  fetchurl,
  comfyuiPackages,
  python3Packages,
  fetchFromGitHub,
  ...
}:
comfyuiPackages.comfyui.mkComfyUICustomNode rec {
  pname = "comfyui-frame-interpolation";
  version = "unstable-2025-04-30";

  src = fetchFromGitHub {
    owner = "Fannovel16";
    repo = "ComfyUI-Frame-Interpolation";
    rev = "a969c01dbccd9e5510641be04eb51fe93f6bfc3d";
    hash = "sha256-bBtGs/LyQf7teCD7YT4dypYQTuy3ja+zV1hbQkYcGuU=";
  };

  dontUseNinjaBuild = true;
  propagatedBuildInputs = with python3Packages; [
    torch
    numpy
    einops
    opencv4 # opencv-contrib-python
    kornia
    scipy
    pillow
    torchvision
    tqdm
  ];
  patches = [
    ./models-path.patch
  ];
}
