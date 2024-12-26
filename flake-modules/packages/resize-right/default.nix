# WARNING: This file was automatically generated. You should avoid editing it.
# If you run pynixify again, the file will be either overwritten or
# deleted, and you will lose the changes you made to it.

{ buildPythonPackage, fetchPypi, lib }:

buildPythonPackage rec {
  pname = "resize-right";
  version = "0.0.2";

  src = fetchPypi {
    inherit pname version;
    sha256 = "087mkbjry4gv20v8kf4alncap4rp2qsrh169gizvf4j0rrr5phvx";
  };

  # TODO FIXME
  doCheck = false;

  meta = with lib; {
    description = "Resize Right";
    homepage = "https://github.com/assafshocher/ResizeRight";
  };
}
