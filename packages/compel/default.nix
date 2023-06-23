{ buildPythonPackage, fetchPypi, lib, setuptools, transformers, diffusers, pyparsing, torch }:

buildPythonPackage rec {
  pname = "compel";
  version = "0.1.7";
  format = "pyproject";

  src = fetchPypi {
    inherit pname version;
    sha256 = "sha256-JP+PX0yENTNnfsAJ/hzgIA/cr/RhIWV1GEa1rYTdlnc=";
  };

  propagatedBuildInputs = [
    setuptools
    diffusers
    pyparsing
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
