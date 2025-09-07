{
  comfyuiPackages,
  fetchFromGitHub,
}:
comfyuiPackages.comfyui.mkComfyUICustomNode {
  pname = "ComfyUI-Logic";
  version = "214cfba";

  src = fetchFromGitHub {
    owner = "theUpsider";
    repo = "ComfyUI-Logic";
    rev = "214cfba933291be224156d37bc30c25742076b44";
    hash = "sha256-O7rQmFKwNl/lDHT3aFyrVkfeUu+t6UqNJ344bHIXa6Q=";
  };
}
