# WARNING: This file was automatically generated. You should avoid editing it.
# If you run pynixify again, the file will be either overwritten or
# deleted, and you will lose the changes you made to it.

{ buildPythonPackage, fetchPypi, lib, numpy, pillow, scipy, torch, torchvision, tqdm }:

buildPythonPackage rec {
  pname = "torch-fidelity";
  version = "0.3.0";

  src = fetchPypi {
    inherit version;
    pname = "torch_fidelity";
    sha256 = "0rib94c1qkhfcf0ag42xj1ydqjz7w4kwn91z9z65k5wik3dk6gix";
  };

  propagatedBuildInputs = [
    numpy
    pillow
    scipy
    torch
    torchvision
    tqdm
  ];

  postUnpack = ''
    #source distribution of torch-fidelity doesn't include this file, while it's used by setup.py
    cp ${./requirements.txt} torch_fidelity-${version}/requirements.txt
    '';

  # TODO FIXME
  doCheck = false;

  meta = with lib; { };
}
