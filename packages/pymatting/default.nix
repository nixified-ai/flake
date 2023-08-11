# WARNING: This file was automatically generated. You should avoid editing it.
# If you run pynixify again, the file will be either overwritten or
# deleted, and you will lose the changes you made to it.

{ buildPythonPackage, fetchPypi, lib, numba, numpy, pillow, scipy }:

buildPythonPackage rec {
  pname = "pymatting";
  version = "1.1.8";

  src = fetchPypi {
    inherit version;
    pname = "PyMatting";
    sha256 = "1k1aacqrpx03vh7d37vq9m40j6hmcfyf716jvwqni6bl13phhdd7";
  };

  propagatedBuildInputs = [ numpy pillow numba scipy ];

  # TODO FIXME
  doCheck = false;

  meta = with lib; {
    description = "Python package for alpha matting.";
    homepage = "https://pymatting.github.io";
  };
}
