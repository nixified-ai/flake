{
  comfyuiPackages,
  fetchFromGitHub,
  ...
}:
comfyuiPackages.comfyui.mkComfyUICustomNode rec {
  pname = "comfyui-wan-start-end-frames-native";
  version = "unstable-2025-03-28";

  src = fetchFromGitHub {
    owner = "Flow-two";
    repo = "ComfyUI-WanStartEndFramesNative";
    rev = "c31ae5dcc278ea25bd2c47456d18342174183992";
    hash = "sha256-/CR5cIngGS31PZVUQSCS5mW4iMJ/kjuK9Y9NTGy7u+s=";
  };
}
