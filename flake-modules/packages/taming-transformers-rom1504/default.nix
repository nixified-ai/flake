# WARNING: This file was automatically generated. You should avoid editing it.
# If you run pynixify again, the file will be either overwritten or
# deleted, and you will lose the changes you made to it.

{ buildPythonPackage, fetchPypi, lib, numpy, omegaconf, pytorch-lightning, torch
, torchvision, tqdm }:

buildPythonPackage rec {
  pname = "taming-transformers-rom1504";
  version = "0.0.6";

  src = fetchPypi {
    inherit pname version;
    sha256 = "0cicin81lr1py2wnrw0amnpkdcksk3h7csgf6r1fxk4a230mzzkk";
  };

  propagatedBuildInputs =
    [ torch torchvision numpy tqdm omegaconf pytorch-lightning ];

  # TODO FIXME
  doCheck = false;

  meta = with lib; {
    description = "Taming Transformers for High-Resolution Image Synthesis";
  };
}
