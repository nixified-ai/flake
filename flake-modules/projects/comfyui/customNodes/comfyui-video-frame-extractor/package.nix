{
  python3Packages,
}:
{
  patches = [ ./comfyui-video-frame-extractor.patch ];
  propagatedBuildInputs = with python3Packages; [
    opencv4
    pillow
    numpy
    torch
  ];
}
