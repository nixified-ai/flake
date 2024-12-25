# WARNING: This file was automatically generated. You should avoid editing it.
# If you run pynixify again, the file will be either overwritten or
# deleted, and you will lose the changes you made to it.

{ buildPythonPackage, fetchPypi, lib, numpy, packaging, psutil, pyyaml, torch, huggingface-hub }:

buildPythonPackage rec {
  pname = "accelerate";
  version = "0.23.0";

  src = fetchPypi {
    inherit pname version;
    sha256 = "sha256-ITnSGfqaN3c8QnnJr+vp9oHy8p6FopsL6NdiV72OSr4=";
  };

  propagatedBuildInputs = [ numpy packaging psutil pyyaml torch huggingface-hub ];

  # TODO FIXME
  doCheck = false;

  meta = with lib; {
    description = "Accelerate";
    homepage = "https://github.com/huggingface/accelerate";
  };
}
