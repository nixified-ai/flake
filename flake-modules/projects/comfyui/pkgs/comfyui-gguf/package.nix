{ comfyuiPackages,
  python3Packages,
  fetchFromGitHub
}:
comfyuiPackages.comfyui.mkComfyUICustomNode {
  pname = "comfyui-gguf";
  version = "unstable-2024-09-09";
  pyproject = false;
  propagatedBuildInputs = with python3Packages; [
    gguf
  ];
  src = fetchFromGitHub {
    owner = "city96";
    repo = "ComfyUI-GGUF";
    rev = "65a7c895bb0ac9547ba2f89d55fbdb609aa2bfe7";
    hash = "sha256-+ohRZam4xFh2ZYVHdwQ5cf1l49SIl6Gm2ECLucRO7UI=";
  };
}
