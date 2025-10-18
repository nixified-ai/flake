{
  python3Packages,
}:
{
  pname = "ComfyUI-VideoHelperSuite";

  propagatedBuildInputs = with python3Packages; [
    opencv4
    #ffmpeg-python
    imageio-ffmpeg
  ];
}
