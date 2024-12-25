{
  buildPythonPackage,
  fetchFromGitHub,
  setuptools,
  numpy,
  opencv4,
  pillow,
}: let
  version = "2.0.57";
in
  buildPythonPackage {
    pname = "pixeloe";
    inherit version;
    src = fetchFromGitHub {
      owner = "KohakuBlueleaf";
      repo = "PixelOE";
      rev = "b5b10ace45f0349a12fc52febf5f433c4a8e4dda";
      sha256 = "sha256-DntAGuBlvr1EvLelrAMcE/dLpsxR5BzuRmQrf/6Uk7c=";
    };
    buildInputs = [
      numpy
      opencv4
      pillow
    ];
    propagatedBuildInputs = [
      setuptools
    ];

    doCheck = false;
  }
