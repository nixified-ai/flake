{
  buildPythonPackage,
  fetchFromGitHub,
  setuptools,
  wheel,
  attrs,
  scipy,
  numpy,
}:
buildPythonPackage rec {
  pname = "pyloudnorm";
  version = "0.1.1";
  format = "setuptools";

  src = fetchFromGitHub {
    owner = "csteinmetz1";
    repo = pname;
    rev = "a741692b186dbb1ca5ae69562d3e4354bc3e761f";
    hash = "sha256-l+MrDomWsXnI+pxw96bFTjMqeEuT/RLJzbEU0oGtcgg=";
  };

  postPatch = ''
    rm pyproject.toml
  '';

  build-system = [
    setuptools
    wheel
    attrs
  ];

  dependencies = [
    scipy
    numpy
  ];

  pythonImportsCheck = [
    "pyloudnorm"
  ];

  # has no tests
  doCheck = false;
}
