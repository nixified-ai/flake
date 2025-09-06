{
  comfyuiPackages,
  fetchFromGitHub,
  ...
}: comfyuiPackages.comfyui.mkComfyUICustomNode
  rec {
    pname = "comfyui-unload-model";
    version = "unstable-2025-06-13";

    src = fetchFromGitHub {
      owner = "SeanScripts";
      repo = "ComfyUI-Unload-Model";
      rev = "ac5ffb4ed05546545ce7cf38e7b69b5152714eed";
      hash = "sha256-+9W5howotJGOepoXSPHP8rGhs+FvAUHtK3ZtPMQ6Y/4=";
    };
  }
