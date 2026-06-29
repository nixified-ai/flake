{
  python3Packages,
}:
{
  postPatch = ''
    substituteInPlace nodes/nodes_graphics_text.py \
      --replace-fail 'font_dir = "/usr/share/fonts/truetype"' \
      'font_dir = os.path.join(os.path.dirname(os.path.dirname(os.path.realpath(__file__))), "fonts")'
    substituteInPlace nodes/nodes_list.py nodes/nodes_xygrid.py \
      --replace-warn 'C:\Windows\Fonts' 'C:\\Windows\\Fonts' \
      --replace-warn 'fonts\Roboto-Regular.ttf' 'fonts\\Roboto-Regular.ttf' \
      --replace-warn 'fonts\Consolas.ttf' 'fonts\\Consolas.ttf'
  '';

  propagatedBuildInputs = with python3Packages; [
    matplotlib
    numpy
    pillow
  ];
}
