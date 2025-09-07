{
  comfyuiPackages,
  fetchFromGitHub,
  ...
}:
comfyuiPackages.comfyui.mkComfyUICustomNode {
  pname = "comfyui-kolors-mz";
  version = "43ec270";

  src = fetchFromGitHub {
    owner = "MinusZoneAI";
    repo = "ComfyUI-Kolors-MZ";
    rev = "43ec2701a1390259a17ef3bea6244a3134aa5153";
    hash = "sha256-E992li2t1x2QLKlcr7WVa0m9oVwew9n+wrRt8oNyeMA=";
  };
}
