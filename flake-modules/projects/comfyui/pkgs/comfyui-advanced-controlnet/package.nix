{
  comfyuiPackages,
  fetchFromGitHub,
  ...
}:
comfyuiPackages.comfyui.mkComfyUICustomNode {
  pname = "advanced-controlnet";
  version = "2025-08-06";

  src = fetchFromGitHub {
    owner = "Kosinkadink";
    repo = "ComfyUI-Advanced-ControlNet";
    rev = "2bde95a468ce5fd3959f646258606ae221fa1e17";
    hash = "sha256-AinLlpYlMNd+gVGyuf0cV7K6B6dwPbFqmkoFLBBMc/k=";
  };
}
