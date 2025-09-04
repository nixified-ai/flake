{
  comfyuiPackages,
  fetchFromGitHub,
  python3Packages,
}: let
  clip-interrogator = python3Packages.callPackage ../../../../packages/clip-interrogator/default.nix {};
  fal-client = python3Packages.callPackage ../../../../packages/fal-client/default.nix {};
  loralib = python3Packages.callPackage ../../../../packages/loralib/default.nix {};
  simple-lama-inpainting = python3Packages.callPackage ../../../../packages/simple-lama-inpainting/default.nix {};
  SenseVoice-python = python3Packages.callPackage ../../../../packages/sensevoice-python/default.nix {};
  swarm = python3Packages.callPackage ../../../../packages/swarm/default.nix {};
in
  comfyuiPackages.comfyui.mkComfyUICustomNode
  {
    pname = "comfyui-mixlab-nodes";
    version = "b2bb187";

    src = fetchFromGitHub {
      owner = "MixLabPro";
      repo = "comfyui-mixlab-nodes";
      rev = "b2bb1876def6330fccf1e03cc69d2166cae7bedb";
      hash = "sha256-22DlP8uOH9C3P4tzIelI6VGlsJjUOooYI2tPFPKJgMI=";
    };

    dontBuild = true;
    doCheck = false;

    pytestCheckPhase = "true";

    propagatedBuildInputs = with python3Packages; [
      numpy
      pyopenssl
      watchdog
      opencv4
      matplotlib
      openai
      torchaudio

      transformers
      lark
      imageio-ffmpeg
      rembg
      omegaconf
      pillow
      einops
      trimesh
      huggingface-hub
      scikit-image
      soundfile
      json-repair

      bitsandbytes
      accelerate
      scenedetect

      hydra-core
      natsort

      faster-whisper
      clip-interrogator
      fal-client
      loralib
      simple-lama-inpainting
      SenseVoice-python
      swarm
    ];
  }
