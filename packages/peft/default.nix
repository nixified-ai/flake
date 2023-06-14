{ buildPythonPackage, fetchPypi, setuptools, packaging, numpy, accelerate, transformers }:

buildPythonPackage rec {
  pname = "peft";
  version = "0.3.0";
  format = "pyproject";

  src = fetchPypi {
    inherit pname version;
    sha256 = "sha256-u97uTeNlPuQ8trvnUFgW5um0z4J1RxvhcH2cJT3+jgs=";
  };

  propagatedBuildInputs = [
    setuptools
    packaging
    numpy
    accelerate
    transformers
  ];

  doCheck = false;

  meta = {
    description = "State-of-the-art Parameter-Efficient Fine-Tuning (PEFT) methods";
    homepage = "https://github.com/huggingface/peft";
  };
}
