{
  python3Packages,
}:
{
  propagatedBuildInputs = with python3Packages; [
    pillow
    numpy
    aiohttp
  ];
}
