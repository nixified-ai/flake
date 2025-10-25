{
  python3Packages,
  config,
}:
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
      sensevoice-python
      swarm
    ]
    ++ lib.optional (config.cudaSupport || config.rocmSupport) bitsandbytes;
}
