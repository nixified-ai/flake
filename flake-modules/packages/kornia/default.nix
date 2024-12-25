# WARNING: This file was automatically generated. You should avoid editing it.
# If you run pynixify again, the file will be either overwritten or
# deleted, and you will lose the changes you made to it.

{ buildPythonPackage, fetchPypi, lib, packaging, pytest-runner, torch }:

buildPythonPackage rec {
  pname = "kornia";
  version = "0.6.8";

  src = fetchPypi {
    inherit pname version;
    sha256 = "0mlcnpqfd411hzn592lgz8pk3asdanks68ld1q1lzay0acjf1189";
  };

  buildInputs = [ pytest-runner ];
  propagatedBuildInputs = [ packaging torch ];

  # TODO FIXME
  doCheck = false;

  meta = with lib; { };
}
