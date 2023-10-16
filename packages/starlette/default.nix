{ buildPythonPackage, fetchPypi, lib, setuptools, anyio }:

buildPythonPackage rec {
  pname = "starlette";
  version = "0.20.4";
  format = "pyproject";

  src = fetchPypi {
    inherit pname version;
    sha256 = "sha256-QvzzEi+Zj+/OPixa1+Xtvw8Cz2hdZGqDoI1ARyavUIQ=";
  };

  propagatedBuildInputs = [
    setuptools
    anyio
  ];
}
