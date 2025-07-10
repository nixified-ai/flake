{
  comfyuiPackages,
  fetchFromGitHub,
  ...
}:
comfyuiPackages.comfyui.mkComfyUICustomNode
{
  pname = "Advanced-ControlNet";
  version = "da254b7";

  src = fetchFromGitHub {
    owner = "Kosinkadink";
    repo = "ComfyUI-Advanced-ControlNet";
    rev = "da254b700db562a22e03358b933c85a9a3392540";
    hash = "sha256-3xNaBOGULhJS4qZICUJ1HLUr71IIaDLFBjd4sM9ytAs=";
  };
}
