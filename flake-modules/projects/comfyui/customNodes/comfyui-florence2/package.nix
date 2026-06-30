{
  python3Packages,
}:
{
  propagatedBuildInputs = with python3Packages; [
    tokenizers
    matplotlib
    pillow
  ];

  postPatch = ''
    substituteInPlace nodes.py \
      --replace-fail 'os.makedirs(model_directory, exist_ok=True)' 'try:
    os.makedirs(model_directory, exist_ok=True)
except OSError:
    pass'
  '';

  dontBuild = true;
  dontConfigure = true;
}
