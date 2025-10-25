{
  buildPythonPackage,
  fetchFromGitHub,
  setuptools,
  setuptools-scm,
  numpy,
  openai,
  pytest,
  requests,
  tqdm,
  pre-commit,
  instructor,
}:
buildPythonPackage rec {
  pname = "swarm";
  version = "0c82d7d";
  format = "pyproject";
  src = fetchFromGitHub {
    owner = "openai";
    repo = "swarm";
    rev = "0c82d7d868bb8e2d380dfd2a319b5c3a1f4c0cb9";
    hash = "sha256-7pjdLNJgz0BW8+YVJFw68ZMHZTRci7wriPwYMpkuBbQ=";
  };

  buildInputs = [
    setuptools
    setuptools-scm
  ];

  propagatedBuildInputs = [
    numpy
    openai
    pytest
    requests
    tqdm
    pre-commit
    instructor
  ];
}
