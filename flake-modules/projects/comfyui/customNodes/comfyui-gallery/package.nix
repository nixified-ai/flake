{
  python3Packages,
}:
{
  pname = "comfyui-gallery";

  propagatedBuildInputs = with python3Packages; [
    pillow
    aiohttp
    piexif
    watchdog
  ];
}
