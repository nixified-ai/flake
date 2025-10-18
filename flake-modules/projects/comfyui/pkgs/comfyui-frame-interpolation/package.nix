{
  fetchurl,
  python3Packages,
  ...
}:
{
  pname = "comfyui-frame-interpolation";

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
