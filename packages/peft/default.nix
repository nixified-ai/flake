{ buildPythonPackage, fetchPypi, lib, setuptools, transformers, diffusers, torch, safetensors, accelerate }:

buildPythonPackage rec {
  pname = "peft";
  version = "0.4.0";
  format = "pyproject";

  src = fetchPypi {
    inherit pname version;
    sha256 = "sha256-52j6Itbp8yqn6JHw0G81WWAnjKTcDN2Wv/cfbwYmkgc=";
  };

  propagatedBuildInputs = [
    setuptools
    transformers
    safetensors
    accelerate
  ];
}
