{ lib
, buildPythonPackage
, fetchPypi
, datasets
, jsonlines
, numexpr
, openai
, pybind11
, pycountry
, pytablewriter
, rouge-score
, sacrebleu
, scikit-learn
, sqlitedict
, torch
, tqdm-multiprocess
, transformers
, zstandard
, pytest
, black
, flake8
, pre-commit
, pytest-cov
, nagisa
, jieba
}:

buildPythonPackage rec {
  pname = "lm-eval";
  version = "0.3.0";

  src = fetchPypi {
    inherit pname version;
    # nix-prefetch-url --unpack https://pypi.io/packages/source/l/lm-eval/lm_eval-0.3.0.tar.gz
    sha256 = "0qnhbvv7ch9945m4v1zpxxz9friwk2x3z0qw1dvn0lvrzw1ifjl3";
  };

  propagatedBuildInputs = [
    datasets
    jsonlines
    numexpr
    openai
    pybind11
    pycountry
    pytablewriter
    rouge-score
    sacrebleu
    scikit-learn
    sqlitedict
    torch
    tqdm-multiprocess
    transformers
    zstandard
  ];

  checkInputs = [ pytest ];
  devInputs = [ black flake8 pre-commit pytest-cov ];
  multilingualInputs = [ nagisa jieba ];

  meta = with lib; {
    description = "A framework for evaluating autoregressive language models";
    homepage = "https://github.com/EleutherAI/lm-evaluation-harness";
    license = licenses.mit;
    maintainers = with maintainers; [ ];
  };
}
