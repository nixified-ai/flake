{
}:
{
  pname = "rgthree";

  patchFlags = [
    "-p1"
    "--binary"
  ];

  patches = [
    ./patches/config.patch
  ];
}
