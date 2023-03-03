{ lib
, buildPythonPackage
, fetchPypi
, setuptools
, writeText
, isPy27
, pytestCheckHook
, pytest-mpl
, numpy
, scipy
, scikit-learn
, pandas
, transformers
, opencv4
, lightgbm
, catboost
, pyspark
, sentencepiece
, tqdm
, slicer
, numba
, matplotlib
, nose
, lime
, cloudpickle
, ipython
, packaging
, pillow
, requests
, regex
, importlib-metadata
, huggingface-hub
}:

buildPythonPackage rec {
  pname = "diffusers";
  version = "0.13.1";

  disabled = isPy27;
  format = "pyproject";

  src = fetchPypi {
    inherit pname version;
    sha256 = "sha256-KbZ6HvNNn1sFw+qwpJZpfaskllLSmNp0JVuKpPxPjkw=";
  };

  propagatedBuildInputs = [
    setuptools
    pillow
    numpy
    requests
    regex
    importlib-metadata
    huggingface-hub
  ];

  doCheck = false;

  meta = with lib; {
    description = "Diffusers";
    homepage = "https://github.com/huggingface/diffusers";
  };
}
