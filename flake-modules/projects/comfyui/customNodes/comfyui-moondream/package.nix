{
  python3Packages,
}:
{
  propagatedBuildInputs = with python3Packages; [
    accelerate
    huggingface-hub
    pillow
    timm
    einops
  ];

  dontBuild = true;
  dontConfigure = true;
}
