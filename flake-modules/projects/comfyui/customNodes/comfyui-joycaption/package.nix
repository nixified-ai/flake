{
  python3Packages,
}:
{
  propagatedBuildInputs = with python3Packages; [
    torch
    transformers
    huggingface-hub
    accelerate
    bitsandbytes
    compressed-tensors
    pillow
    llama-cpp-python
  ];

  dontBuild = true;
  dontConfigure = true;
}
