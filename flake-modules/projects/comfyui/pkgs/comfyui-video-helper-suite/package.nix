{
  comfyuiPackages,
  fetchFromGitHub,
  python3Packages,
}:
comfyuiPackages.comfyui.mkComfyUICustomNode {
  pname = "ComfyUI-VideoHelperSuite";
  version = "a7ce59e";

  src = fetchFromGitHub {
    owner = "Kosinkadink";
    repo = "ComfyUI-VideoHelperSuite";
    rev = "a7ce59e381934733bfae03b1be029756d6ce936d";
    hash = "sha256-URa1xJQoJNZiA4vWxR8OVqRDJ9fzYHyI1QufxFIFfic=";
  };
  propagatedBuildInputs = with python3Packages; [
    opencv4
    #ffmpeg-python
    imageio-ffmpeg
  ];
}
