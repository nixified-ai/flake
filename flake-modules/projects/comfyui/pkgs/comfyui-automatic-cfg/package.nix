{
  comfyuiPackages,
  python3Packages,
  fetchFromGitHub,
  ...
}:
comfyuiPackages.comfyui.mkComfyUICustomNode {
  pname = "automatic-cfg";
  version = "2e39531";

  propagatedBuildInputs = with python3Packages; [
    colorama
  ];

  src = fetchFromGitHub {
    owner = "Extraltodeus";
    repo = "ComfyUI-AutomaticCFG";
    rev = "2e395317b65c05a97a0ef566c4a8c7969305dafa";
    hash = "sha256-Kc7JK53V3ptypJUNTyE4OPSZzWhIMYBAak6aJRZsscU=";
  };
}
