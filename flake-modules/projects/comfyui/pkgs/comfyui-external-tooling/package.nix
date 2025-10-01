{
  comfyuiPackages,
  fetchFromGitHub,
  ...
}:
comfyuiPackages.comfyui.mkComfyUICustomNode
{
  pname = "comfyui-tooling-nodes";
  version = "5ef2fdd";

  src = fetchFromGitHub {
    owner = "Acly";
    repo = "comfyui-tooling-nodes";
    rev = "5ef2fddc1ba5fc2dc38286a29f97268be4e25343";
    hash = "sha256-NZhcyGplF363s6vxHaylzcvJ/rKbVDLgyW6bz4Rx/Bc=";
  };
}
