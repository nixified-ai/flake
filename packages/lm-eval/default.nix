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

  postPatch = ''
    substituteInPlace setup.py --replace "'nagisa>=0.2.7', 'jieba>=0.42.1'" ""
  '';

  # some tests try to connect to the Hugging Face Hub
  doCheck = false;

  preCheck = ''
    export TRANSFORMERS_CACHE=$(mktemp -d)
  '';

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

  meta = with lib; {
    description = "A framework for evaluating autoregressive language models";
    homepage = "https://github.com/EleutherAI/lm-evaluation-harness";
    license = licenses.mit;
    maintainers = with maintainers; [ ];
  };
}
