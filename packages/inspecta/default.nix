# WARNING: This file was automatically generated. You should avoid editing it.
# If you run pynixify again, the file will be either overwritten or
# deleted, and you will lose the changes you made to it.

{ buildPythonPackage, codecov, colour-runner, coverage, deepdiff, fetchPypi, lib
, pygments, rootpath, setuptools-git, six, termcolor, tox }:

buildPythonPackage rec {
  pname = "inspecta";
  version = "0.1.3";

  src = fetchPypi {
    inherit pname version;
    sha256 = "1hfnqfgclx442y2wrr8ssqvxzfrnfym3cq22rhk64pmhx7x4s4hp";
  };

  buildInputs = [ setuptools-git ];
  propagatedBuildInputs = [
    rootpath
    six
    pygments
    termcolor
    colour-runner
    deepdiff
    tox
    coverage
    codecov
  ];

  # TODO FIXME
  doCheck = false;

  meta = with lib; {
    description = "A colorized object pretty printer - for Python.";
    homepage = "https://github.com/grimen/python-inspecta";
  };
}
