{
  python3Packages,
}:
{
  pname = "comfyui-wanmoeksampler";
  propagatedBuildInputs = with python3Packages; [
    gguf
    sentencepiece
    protobuf
  ];
}
