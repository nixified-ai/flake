{
  python3Packages,
}:
let
  blend-modes = python3Packages.callPackage ../../../../packages/blend-modes/default.nix { };
  colour-science = python3Packages.callPackage ../../../../packages/colour-science/default.nix { };
  segment-anything =
    python3Packages.callPackage ../../../../packages/segment-anything/default.nix
      { };
  mediapipe = python3Packages.callPackage ../../../../packages/mediapipe/default.nix { };
  typer-config = python3Packages.callPackage ../../../../packages/typer-config/default.nix { };
  transparent-background =
    python3Packages.callPackage ../../../../packages/transparent-background/default.nix
      { };
  blind-watermark = python3Packages.callPackage ../../../../packages/blind-watermark/default.nix { };
  zhipuai = python3Packages.callPackage ../../../../packages/zhipuai/default.nix { };
in
{
  pname = "comfyui-layer-style-advance";

  dontBuild = true;

  propagatedBuildInputs = with python3Packages; [
    matplotlib
    scikit-image
    scikit-learn
    opencv4
    # Tests for this package fail with cudaSupport=true
    (pymatting.override { cudaSupport = false; })
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
    mediapipe
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
    bitsandbytes
    peft
    protobuf
    hydra-core
    blind-watermark
    qrcode
    pyzbar
    psd-tools
    zhipuai
    openai
  ];
}
