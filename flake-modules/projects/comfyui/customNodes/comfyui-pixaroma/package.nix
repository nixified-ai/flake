{
  python3Packages,
  ...
}:
{
  propagatedBuildInputs = with python3Packages; [
    toml
    rembg
    onnxruntime
  ];
  dontBuild = true;
  dontConfigure = true;
}
