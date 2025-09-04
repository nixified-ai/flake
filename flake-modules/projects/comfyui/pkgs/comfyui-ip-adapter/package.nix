{
  comfyuiPackages,
  fetchFromGitHub,
}:
comfyuiPackages.comfyui.mkComfyUICustomNode
{
  pname = "ComfyUI_IPAdapter_plus";
  version = "a0f451a";

  src = fetchFromGitHub {
    owner = "cubiq";
    repo = "ComfyUI_IPAdapter_plus";
    rev = "a0f451a5113cf9becb0847b92884cb10cbdec0ef";
    hash = "sha256-Ft9WJcmjzon2tAMJq5na24iqYTnQWEQFSKUElSVwYgw=";
  };
}
