{
  comfyuiPackages,
  fetchFromGitHub,
  ...
}:
comfyuiPackages.comfyui.mkComfyUICustomNode
{
  pname = "comfyui-tiled-diffusion";
  version = "unstable-2025-05-18";
  src = fetchFromGitHub {
    owner = "shiimizu";
    repo = "ComfyUI-TiledDiffusion";
    rev = "a155b1bac39147381aeaa52b9be42e545626a44f";
    hash = "sha256-UDcjTWyA2kQKyeX5pZuvX0RnVAz56WCbak0JGSy4w0Y=";
  };
}
