# WARNING: This file was automatically generated. You should avoid editing it.
# If you run pynixify again, the file will be either overwritten or
# deleted, and you will lose the changes you made to it.

{ buildPythonPackage, fetchPypi, lib, scipy, torch }:

buildPythonPackage rec {
  pname = "torchdiffeq";
  version = "0.2.3";

  src = fetchPypi {
    inherit pname version;
    sha256 = "06m37q0x9igda4gmirjv0f3hyas747njpq02fz1c02h9p4sg8xgy";
  };

  propagatedBuildInputs = [ torch scipy ];

  # TODO FIXME
  doCheck = false;

  meta = with lib; {
    description = "ODE solvers and adjoint sensitivity analysis in PyTorch.";
    homepage = "https://github.com/rtqichen/torchdiffeq";
  };
}
