# WARNING: This file was automatically generated. You should avoid editing it.
# If you run pynixify again, the file will be either overwritten or
# deleted, and you will lose the changes you made to it.

{ blessings, buildPythonPackage, fetchPypi, lib, pygments }:

buildPythonPackage rec {
  pname = "colour-runner";
  version = "0.1.1";

  src = fetchPypi {
    inherit pname version;
    sha256 = "1y9rk4phr3n15n8y0c1chmjy3jzncdmh4fcfidx52jn3zwqsvc9q";
  };

  propagatedBuildInputs = [ blessings pygments ];

  # TODO FIXME
  doCheck = false;

  meta = with lib; {
    description = "Colour formatting for unittest tests";
    homepage = "https://github.com/meshy/colour-runner";
  };
}
