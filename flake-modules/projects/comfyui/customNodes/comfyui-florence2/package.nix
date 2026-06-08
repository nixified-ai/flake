{
  python3Packages,
}:
{
  propagatedBuildInputs = with python3Packages; [
    tokenizers
    matplotlib
    pillow
  ];

  dontBuild = true;
  dontConfigure = true;
}
