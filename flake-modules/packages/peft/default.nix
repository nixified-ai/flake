{ lib
, buildPythonPackage
, fetchPypi
, accelerate
, numpy
, packaging
, psutil
, pyyaml
, torch
, transformers
, black
, hf-doc-builder
, ruff
}:

buildPythonPackage rec {
  pname = "peft";
  version = "0.2.0";
  format = "pyproject";

  src = fetchPypi {
    inherit pname version;
    hash = "sha256-zjP0hMcDgZBwW2nk0iiSMMfBgZwQhHgUg6yOEY8Kca8=";
  };

  propagatedBuildInputs = [
    accelerate
    numpy
    packaging
    psutil
    pyyaml
    torch
    transformers
  ];

  passthru.optional-dependencies = {
    dev = [
      black
      hf-doc-builder
      ruff
    ];
    docs_specific = [
      hf-doc-builder
    ];
    quality = [
      black
      ruff
    ];
  };

  pythonImportsCheck = [ "peft" ];

  meta = with lib; {
    description = "Parameter-Efficient Fine-Tuning (PEFT";
    homepage = "https://github.com/huggingface/peft";
    license = licenses.asl20;
    maintainers = with maintainers; [ jpetrucciani ];
  };
}
