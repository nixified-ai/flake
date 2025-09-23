{
  comfyuiPackages,
  python3Packages,
  fetchFromGitHub,
  ...
}:
comfyuiPackages.comfyui.mkComfyUICustomNode rec {
  pname = "comfyui-last-frame-extractor";
  version = "unstable-2025-08-14";

  src = fetchFromGitHub {
    owner = "Charonartist";
    repo = "comfyui-last-frame-extractor";
    rev = "30f294b1a0a87c7abaf979f04ee74d887a87f027";
    hash = "sha256-t41rXtFlEXHBNSUk42oWwUTs3Zi3SddX3T+raaOL6vM=";
  };
  pyproject = false;
}
