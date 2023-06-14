{ buildPythonPackage, fetchPypi, setuptools, anyio, pydantic }:

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
    pydantic
  ];

  doCheck = false;

  meta = {
    description = "Starlette is a lightweight ASGI framework/toolkit, which is ideal for building async web services in Python.";
    homepage = "https://github.com/encode/starlette";
  };
}
