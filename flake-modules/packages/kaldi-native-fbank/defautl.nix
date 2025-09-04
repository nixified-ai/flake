{
  pkgs,
  lib,
  ...
}:
pkgs.python3Packages.buildPythonPackage
rec {
  pname = "kaldi-native-fbank";
  version = "1.21.3";
  #format = "pyproject";
  format = "setuptools";

  src = pkgs.fetchFromGitHub {
    owner = "csukuangfj";
    repo = "kaldi-native-fbank";
    rev = "v${version}";
    hash = "sha256-NZxeedKcsKz+XApONgEFvFkWVVbG0hpR6vZDK5rBEUY=";
  };

  patches = [./fix.patch];

  nativeBuildInputs = with pkgs.python3Packages; [
    setuptools
    cmake
    wheel
    cmake-build-extension
  ];

  env.NIX_CFLAGS_COMPILE = "-I${lib.getInclude pkgs.kissfft}/include";
  #preConfigure = ''
  #  pwd
  #  ls -lp
  #'';

  preBuild = ''
    cd ..
    #cp ../setup.py ./
    #cp -r ../kaldi-native-fbank ./
    #cp -r ../CMakeLists.txt ./
    #cp -r ../README.md ./
    #cp -r ../LICENSE ./
  '';
  buildInputs = with pkgs; [
    kissfft
    gtest
    python3Packages.pybind11
    extra-cmake-modules
  ];

  propagatedBuildInputs = with pkgs; [
    kissfft
    gtest
    python3Packages.pybind11
    extra-cmake-modules
  ];
}
