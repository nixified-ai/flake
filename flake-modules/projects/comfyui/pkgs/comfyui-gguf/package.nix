{
  python3Packages,
}:
{
  pname = "comfyui-gguf";
  propagatedBuildInputs = with python3Packages; [
    gguf
    sentencepiece
    protobuf
  ];
}
