# WARNING: This file was automatically generated. You should avoid editing it.
# If you run pynixify again, the file will be either overwritten or
# deleted, and you will lose the changes you made to it.

{ buildPythonPackage, codecov, coloredlogs, colour-runner, coverage, deepdiff
, fetchPypi, lib, pygments, setuptools-git, six, termcolor, tox }:

buildPythonPackage rec {
  pname = "rootpath";
  version = "0.1.1";

  src = fetchPypi {
    inherit pname version;
    sha256 = "13siki2yc8d7kdbyizaymlg4rdywwhln558fvrm1rw8g53ggkhzc";
  };

  buildInputs = [ setuptools-git ];
  propagatedBuildInputs = [
    six
    coloredlogs
    termcolor
    colour-runner
    deepdiff
    pygments
    tox
    coverage
    codecov
  ];

  # TODO FIXME
  doCheck = false;

  meta = with lib; {
    description = "Python project/package root path detection.";
    homepage = "https://github.com/grimen/python-rootpath";
  };
}
