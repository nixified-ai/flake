{
  python3Packages,
}:
{
  propagatedBuildInputs = with python3Packages; [
    llama-cpp-python
    pillow
    json-repair
    colorama
  ];

  dontBuild = true;
  dontConfigure = true;
}
