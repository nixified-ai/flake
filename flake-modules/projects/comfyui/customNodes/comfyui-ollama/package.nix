{
  python3Packages,
}:
{
  propagatedBuildInputs = with python3Packages; [
    ollama
    python-dotenv
  ];

  dontBuild = true;
  dontConfigure = true;
}
