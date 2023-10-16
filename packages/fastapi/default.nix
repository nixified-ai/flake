{ buildPythonPackage, fetchPypi, lib, setuptools, hatchling, pydantic, starlette }:

buildPythonPackage rec {
  pname = "fastapi";
  version = "0.85.0";
  format = "pyproject";

  src = fetchPypi {
    inherit pname version;
    sha256 = "sha256-uyGc+v0NLM+PMjEMmiV6BrAhC9jioDcGpvWp+fFBaHg=";
  };

  propagatedBuildInputs = [
    setuptools
    hatchling
    pydantic
    starlette
  ];
}
