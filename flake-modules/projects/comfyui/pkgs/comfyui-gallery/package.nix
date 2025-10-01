{
  comfyuiPackages,
  fetchFromGitHub,
  python3Packages,
}:
comfyuiPackages.comfyui.mkComfyUICustomNode
{
  pname = "comfyui-gallery";
  version = "unstable-2025-07-10";

  src = fetchFromGitHub {
    owner = "PanicTitan";
    repo = "ComfyUI-Gallery";
    rev = "91b81eb3ad6a65fa19498a9b22603242b2f06487";
    hash = "sha256-9vR7CWkQ54Qp4SQstidcjDPcLoXtfvGiBpq7rB1b/GI=";
  };

  propagatedBuildInputs = with python3Packages; [
    pillow
    aiohttp
    piexif
    watchdog
  ];
}
