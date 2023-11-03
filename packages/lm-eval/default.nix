{ lib
, buildPythonPackage
, fetchFromGitHub
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

  src = fetchFromGitHub {
    owner = "EleutherAI";
    repo = "lm-evaluation-harness";
    rev = "v${version}";
    sha256 = "1s2ayvkn9nqmfrayjwrb21xv6sb4qy5hw7vwcbfxpviw47q7m87y";
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
