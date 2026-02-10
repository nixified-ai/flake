{
  python3Packages,
}:
{
  pyproject = false;
  propagatedBuildInputs = with python3Packages; [
    qrcode
    onnxruntime
    requirements-parser
    rembg
    imageio-ffmpeg
    rich
    rich-argparse
    matplotlib
    pillow
    cachetools
    transformers
  ];
}
