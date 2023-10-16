{ buildPythonPackage, fetchPypi, lib, setuptools, transformers, diffusers, torch }:

buildPythonPackage rec {
  pname = "compel";
  version = "1.1.0";
  format = "pyproject";

  src = fetchPypi {
    inherit pname version;
    sha256 = "sha256-CNP1nh8LHojtb0cFgm9ZLemMAQqbMQnJRTjJTkANPGU=";
  };

  propagatedBuildInputs = [
    setuptools
    diffusers
    transformers
    torch
  ];
}
