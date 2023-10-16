{ buildPythonPackage, fetchPypi, lib, setuptools, starlette }:

buildPythonPackage rec {
  pname = "fastapi-events";
  version = "0.6.0";
  format = "pyproject";

  src = fetchPypi {
    inherit pname version;
    sha256 = "sha256-I4DNw+MNyJjWtyHWI8V1xvWwXuNaPuBa3wuQsSue0fk=";
  };

  propagatedBuildInputs = [
    setuptools
    starlette
  ];

}
