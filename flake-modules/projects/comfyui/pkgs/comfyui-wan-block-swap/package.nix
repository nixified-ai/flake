{
  comfyuiPackages,
  fetchFromGitHub,
  ...
}:
comfyuiPackages.comfyui.mkComfyUICustomNode rec {
  pname = "comfyui-wan-block-swap";
  version = "unstable-2025-03-19";

  src = fetchFromGitHub {
    owner = "orssorbit";
    repo = "ComfyUI-wanBlockswap";
    rev = "5fa2ec0fa55879fe43a33e762fff91fc2c553a67";
    hash = "sha256-RALhFov6bYUyOer3iv//iypc/PIvzumIzrvtFdnNyYc=";
  };
}
