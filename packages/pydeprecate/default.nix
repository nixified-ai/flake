# WARNING: This file was automatically generated. You should avoid editing it.
# If you run pynixify again, the file will be either overwritten or
# deleted, and you will lose the changes you made to it.

{ buildPythonPackage, fetchPypi, lib }:

buildPythonPackage rec {
  pname = "pydeprecate";
  version = "0.3.2";

  src = fetchPypi {
    inherit version;
    pname = "pyDeprecate";
    sha256 = "0afxbg5scrlydqkm1cwlnlb0mffrzl785gn4wxrw9xnpqmn130fl";
  };

  # TODO FIXME
  doCheck = false;

  meta = with lib; {
    description = "Deprecation tooling";
    homepage = "https://borda.github.io/pyDeprecate";
  };
}
