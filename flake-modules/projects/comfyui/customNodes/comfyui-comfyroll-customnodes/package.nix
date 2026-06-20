{
  python3Packages,
}:
{
  postPatch = ''
    substituteInPlace nodes/nodes_graphics_text.py \
      --replace-fail 'font_dir = "/usr/share/fonts/truetype"' \
      'font_dir = os.path.join(os.path.dirname(os.path.dirname(os.path.realpath(__file__))), "fonts")'
  '';

  propagatedBuildInputs = with python3Packages; [
    matplotlib
    numpy
    pillow
  ];
}
