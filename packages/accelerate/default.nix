# WARNING: This file was automatically generated. You should avoid editing it.
# If you run pynixify again, the file will be either overwritten or
# deleted, and you will lose the changes you made to it.

{ buildPythonPackage, fetchPypi, lib, numpy, packaging, psutil, pyyaml, torch }:

buildPythonPackage rec {
  pname = "accelerate";
  version = "0.16.0";

  src = fetchPypi {
    inherit pname version;
    sha256 = "sha256-0T4w8+bev7Rsrae5Ma+FVgYZtqaoOdDK/uq27XxqSY0=";
  };

  propagatedBuildInputs = [ numpy packaging psutil pyyaml torch ];

  # TODO FIXME
  doCheck = false;

  meta = with lib; {
    description = "Accelerate";
    homepage = "https://github.com/huggingface/accelerate";
  };
}
