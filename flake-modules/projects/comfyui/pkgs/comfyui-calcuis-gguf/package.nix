{
  python3Packages,
}:
{
  pname = "comfyui-calcuis-gguf";
  propagatedBuildInputs = with python3Packages; [
    gguf
    sentencepiece
    protobuf
  ];
}
