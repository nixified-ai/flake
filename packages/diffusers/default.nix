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
  version = "0.14.0";

  disabled = isPy27;
  format = "pyproject";

  src = fetchPypi {
    inherit pname version;
    sha256 = "sha256-sqQqEtq1OMtFo7DGVQMFO6RG5fLfSDbeOFtSON+DCkY=";
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
