{
  python3Packages,
  ...
}:
{
  propagatedBuildInputs = with python3Packages; [
    llama-cpp-python
    numpy
    pillow
  ];
}
