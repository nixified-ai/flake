{ buildPythonPackage, fetchPypi, lib, setuptools, diffusers, torch, tokenizers }:

buildPythonPackage rec {
  pname = "transformers";
  version = "4.26.0";
  format = "pyproject";

  src = fetchPypi {
    inherit pname version;
    sha256 = "sha256-14Wb2Dgpo2gspjIZfuXHJVbhBj0ZmrhO7DXE8js9c6M=";
  };

  propagatedBuildInputs = [
    setuptools
    diffusers
    torch
    tokenizers
  ];

#  # TODO FIXME
  doCheck = false;

  meta = {
    description = "A prompting enhancement library for transformers-type text embedding systems";
    homepage = "https://github.com/damian0815/compel";
  };
}
