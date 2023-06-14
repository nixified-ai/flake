{ buildPythonPackage, fetchPypi, setuptools, tqdm, pyyaml, fsspec, filelock, packaging }:

buildPythonPackage rec {
  pname = "huggingface-hub";
  version = "0.15.1";
  format = "pyproject";

  src = fetchPypi {
    inherit version;
    pname = "huggingface_hub";
    sha256 = "sha256-pht9Gndp/hARnnMCd8cquZ2VxI2Go9baPp89D2MqQIE=";
  };

  propagatedBuildInputs = [
    setuptools
    tqdm
    pyyaml
    fsspec
    filelock
    packaging
  ];

  doCheck = false;

  meta = {
    description = "The huggingface_hub is a client library to interact with the Hugging Face Hub.";
    homepage = "https://github.com/huggingface/huggingface_hub";
  };
}
