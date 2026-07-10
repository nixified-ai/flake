{
  python3Packages,
}:
{
  propagatedBuildInputs = with python3Packages; [
    scipy
    triton
    safetensors
  ];

  dontBuild = true;
  dontConfigure = true;
}
