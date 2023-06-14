{ buildPythonPackage, fetchPypi, hatchling, starlette }:

buildPythonPackage rec {
  pname = "fastapi";
  version = "0.85.0";
  format = "pyproject";

  src = fetchPypi {
    inherit pname version;
    sha256 = "sha256-uyGc+v0NLM+PMjEMmiV6BrAhC9jioDcGpvWp+fFBaHg=";
  };

  propagatedBuildInputs = [
    hatchling
    starlette
  ];

  doCheck = false;

  meta = {
    description = "FastAPI is a modern, fast (high-performance), web framework for building APIs with Python 3.7+ based on standard Python type hints.";
    homepage = "https://github.com/tiangolo/fastapi";
  };
}
