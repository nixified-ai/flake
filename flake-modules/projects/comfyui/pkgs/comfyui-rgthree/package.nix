{
  comfyuiPackages,
  fetchFromGitHub,
}:
comfyuiPackages.comfyui.mkComfyUICustomNode {
  pname = "rgthree";
  version = "84a146f";

  src = fetchFromGitHub {
    owner = "rgthree";
    repo = "rgthree-comfy";
    rev = "84a146fee39f7b3a8c6631dcac29bc13b077eb49";
    hash = "sha256-CpiKp1Qhu6MjsuI88yT7OCZi+0a4a6UFpEdzBqScWtY=";
  };
}
