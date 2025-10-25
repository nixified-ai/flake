{
  python3Packages,
  gccStdenv,
  config,
}:
{
  pname = "comfyui-kijai-wan-video-wrapper";
  pyproject = false;
  propagatedBuildInputs =
    with python3Packages;
    [
      ftfy
      accelerate
      einops
      diffusers
      peft
      sentencepiece
      protobuf
      pyloudnorm
      gguf
      gccStdenv.cc
    ]
    ++ lib.optional config.cudaSupport sageattention;
  dontUseNinjaBuild = true;
}
