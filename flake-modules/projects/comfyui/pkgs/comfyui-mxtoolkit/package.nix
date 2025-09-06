{
  comfyuiPackages,
  fetchFromGitHub,
  ...
}:
comfyuiPackages.comfyui.mkComfyUICustomNode
{
  pname = "comfyui-mxtoolkit";
  version = "unstable-2025-05-07";

  src = fetchFromGitHub {
    owner = "Smirnov75";
    repo = "ComfyUI-mxToolkit";
    rev = "7f7a0e584f12078a1c589645d866ae96bad0cc35";
    hash = "sha256-0vf6rkDzUvsQwhmOHEigq1yUd/VQGFNLwjp9/P9wJ10=";
  };
}
