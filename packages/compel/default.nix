{ buildPythonPackage, fetchPypi, lib, setuptools, transformers, diffusers, torch }:

buildPythonPackage rec {
  pname = "compel";
  version = "1.1.5";
  format = "pyproject";

  src = fetchPypi {
    inherit pname version;
    sha256 = "sha256-kypESFU5g9sz9Ik1FiOe1QAbOEzCEeMoQegLH5Tc0PY=";
  };

  propagatedBuildInputs = [
    setuptools
    diffusers
    transformers
    torch
  ];

#  # TODO FIXME
  doCheck = false;

  meta = {
    description = "A prompting enhancement library for transformers-type text embedding systems";
    homepage = "https://github.com/damian0815/compel";
  };
}
