# WARNING: This file was automatically generated. You should avoid editing it.
# If you run pynixify again, the file will be either overwritten or
# deleted, and you will lose the changes you made to it.

{ buildPythonPackage, fetchPypi, lib }:

buildPythonPackage rec {
  pname = "pyreadline3";
  version = "3.4.1";

  src = fetchPypi {
    inherit pname version;
    sha256 = "1bkv3zrfzmhbsd38dslsydi0arnc50gzrkhp76vk5fiii9xiygbg";
  };

  # TODO FIXME
  doCheck = false;

  meta = with lib; { };
}
