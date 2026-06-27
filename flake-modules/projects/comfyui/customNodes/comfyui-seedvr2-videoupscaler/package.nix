{ pkgs, ... }:
{
  dontUseNinjaBuild = true;

  postPatch = ''
    substituteInPlace src/optimization/compatibility.py \
      --replace-fail "if not (hasattr(torch, 'cuda') and torch.cuda.is_available()):" "if not (hasattr(torch, 'cuda') and torch.cuda.is_available() and torch.cuda.device_count() > 0):"
    substituteInPlace src/interfaces/vae_model_loader.py \
      --replace-fail "devices = get_device_list()" "devices = get_device_list() or ['cpu']"
    substituteInPlace src/interfaces/dit_model_loader.py \
      --replace-fail "devices = get_device_list()" "devices = get_device_list() or ['cpu']"
  '';

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
