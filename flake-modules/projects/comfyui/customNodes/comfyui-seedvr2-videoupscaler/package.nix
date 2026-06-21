{ pkgs, ... }:
{
  dontUseNinjaBuild = true;
  propagatedBuildInputs = with pkgs.python3Packages; [
    torch
    torchvision
    safetensors
    numpy
    tqdm
    psutil
    einops
    omegaconf
    diffusers
    peft
    rotary-embedding-torch
    opencv4
    gguf
    matplotlib
  ];
}
