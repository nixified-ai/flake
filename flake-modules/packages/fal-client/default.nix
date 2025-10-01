{
  buildPythonPackage,
  fetchPypi,
  setuptools,
  setuptools-scm,
  httpx,
  httpx-sse,
}:
buildPythonPackage rec {
  pname = "fal-client";
  version = "0.7.0";
  format = "pyproject";
  src = fetchPypi {
    inherit version;
    pname = "fal_client";
    hash = "sha256-m/As/FasiVcVnoqVnvCMV+VhjOrCz/VS9yBDNjuSpy8=";
  };
  buildInputs = [
    setuptools
    setuptools-scm
  ];

  propagatedBuildInputs = [
    httpx
    httpx-sse
  ];
}
