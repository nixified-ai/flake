# WARNING: This file was automatically generated. You should avoid editing it.
# If you run pynixify again, the file will be either overwritten or
# deleted, and you will lose the changes you made to it.

{ buildPythonPackage, fetchPypi, huggingface-hub, lib, pyyaml, torch
, torchvision }:

buildPythonPackage rec {
  pname = "timm";
  version = "0.6.11";

  src = fetchPypi {
    inherit pname version;
    sha256 = "199zgg574gijw52jn4fhfzaqlbwhq0z8kav4k34xifssnr18hmh9";
  };

  propagatedBuildInputs = [ torch torchvision pyyaml huggingface-hub ];

  # TODO FIXME
  doCheck = false;

  meta = with lib; {
    description = "(Unofficial) PyTorch Image Models";
    homepage = "https://github.com/rwightman/pytorch-image-models";
  };
}
