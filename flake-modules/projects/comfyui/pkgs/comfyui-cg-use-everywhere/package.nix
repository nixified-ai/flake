{
  comfyuiPackages,
  fetchFromGitHub,
  ...
}:
comfyuiPackages.comfyui.mkComfyUICustomNode
{
  pname = "comfyui-cg-use-everywhere";
  version = "unstable-2025-09-01";

  src = fetchFromGitHub {
    owner = "chrisgoringe/";
    repo = "cg-use-everywhere";
    rev = "1dc7ea7ad976daacb4efc7b6cadab0afd0088adc";
    hash = "sha256-kIKzTlQoFuJf4Cl1STRd/0oWTCMeWwX3PfZXHXWhLY4=";
  };
}
