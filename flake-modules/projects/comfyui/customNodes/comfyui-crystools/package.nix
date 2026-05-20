{
  python3Packages,
}:
{
  propagatedBuildInputs = with python3Packages; [
    deepdiff
    nvidia-ml-py
    py-cpuinfo
    piexif
  ];
  patches = [
    ./css-path.patch
  ];
}
