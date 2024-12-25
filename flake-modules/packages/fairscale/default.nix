# WARNING: This file was automatically generated. You should avoid editing it.
# If you run pynixify again, the file will be either overwritten or
# deleted, and you will lose the changes you made to it.

{ buildPythonPackage, fetchPypi, lib, ninja, numpy, torch}:

buildPythonPackage rec {
  pname = "fairscale";
  version = "0.4.12";

  src = fetchPypi {
    inherit pname version;
    sha256 = "0zjgdida0bxvi4dx1dgq0sfl6h7cjmkma5c1rxbwym97p8aqcs3g";
  };

  nativeBuildInputs = [ ninja ];
  propagatedBuildInputs = [ torch numpy ];
  patches = [ ./ninja_remove.patch ];

  # TODO FIXME
  doCheck = false;

  meta = with lib; {
    description =
      "FairScale: A PyTorch library for large-scale and high-performance training.";
  };
}
