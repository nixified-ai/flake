{
  python3Packages,
  ...
}:
{
  pname = "automatic-cfg";

  propagatedBuildInputs = with python3Packages; [
    colorama
  ];

}
