{
  python3Packages,
}:
finalAttrs: previousAttrs: {
  propagatedBuildInputs = with python3Packages; [
    psutil
  ];
}
