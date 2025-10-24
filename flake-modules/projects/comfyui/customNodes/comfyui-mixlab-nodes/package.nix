{
  python3Packages,
  config,
}:
let
  clip-interrogator =
    python3Packages.callPackage ../../../../packages/clip-interrogator/default.nix
      { };
  fal-client = python3Packages.callPackage ../../../../packages/fal-client/default.nix { };
  loralib = python3Packages.callPackage ../../../../packages/loralib/default.nix { };
  simple-lama-inpainting =
    python3Packages.callPackage ../../../../packages/simple-lama-inpainting/default.nix
      { };
  SenseVoice-python =
    python3Packages.callPackage ../../../../packages/sensevoice-python/default.nix
      { };
  swarm = python3Packages.callPackage ../../../../packages/swarm/default.nix { };
in
{
  pname = "comfyui-mixlab-nodes";

  dontBuild = true;
  doCheck = false;

  pytestCheckPhase = "true";

  propagatedBuildInputs =
    with python3Packages;
    [
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
    ]
    ++ lib.optional (config.cudaSupport || config.rocmSupport) bitsandbytes;
}
