{
  python3Packages,
  config,
}:
{
  pname = "comfyui-layer-style-advance";

  dontBuild = true;

  propagatedBuildInputs =
    with python3Packages;
    [
      matplotlib
      scikit-image
      scikit-learn
      opencv4
      pymatting
      timm
      blend-modes
      transformers
      diffusers
      loguru
      colour-science
      huggingface-hub
      segment-anything
      addict
      omegaconf
      yapf
      wget
      iopath
      # mediapipe
      typer-config
      fastapi
      rich
      google-generativeai
      google-genai
      pillow
      ultralytics
      transparent-background
      accelerate
      onnxruntime
      peft
      protobuf
      hydra-core
      blind-watermark
      qrcode
      pyzbar
      psd-tools
      zhipuai
      openai
    ]
    ++ lib.optional (config.cudaSupport || config.rocmSupport) bitsandbytes;
}
