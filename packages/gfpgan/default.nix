# WARNING: This file was automatically generated. You should avoid editing it.
# If you run pynixify again, the file will be either overwritten or
# deleted, and you will lose the changes you made to it.

{ basicsr, buildPythonPackage, cython, facexlib, fetchPypi, lib, lmdb, numpy
, opencv-python, pyyaml, scipy, torch, torchvision, tqdm, yapf, tensorboard }:

buildPythonPackage rec {
  pname = "gfpgan";
  version = "1.3.8";

  src = fetchPypi {
    inherit pname version;
    sha256 = "1yf4c25grfb97y1mrdanp6d3mwh4400nnlnb902279lfrq38nq91";
  };

  buildInputs = [ cython numpy ];
  propagatedBuildInputs = [
    basicsr
    facexlib
    lmdb
    numpy
    opencv-python
    pyyaml
    scipy
    torch
    torchvision
    tqdm
    yapf
    tensorboard
  ];

  # TODO FIXME
  doCheck = false;

  meta = with lib; {
    description =
      "GFPGAN aims at developing Practical Algorithms for Real-world Face Restoration";
    homepage = "https://github.com/TencentARC/GFPGAN";
  };
}
