{
  python3Packages,
}:
{
  pname = "comfyui-adv-clip-emb";
  propagatedBuildInputs = with python3Packages; [
    gguf
    sentencepiece
    protobuf
  ];
}
