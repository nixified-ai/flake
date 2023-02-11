# WARNING: This file was automatically generated. You should avoid editing it.
# If you run pynixify again, the file will be either overwritten or
# deleted, and you will lose the changes you made to it.

{ addict, buildPythonPackage, cython, fetchPypi, future, lib, lmdb, numpy
, opencv-python, pillow, pyyaml, requests, scikit-image, scipy, torch
, torchvision, tqdm, yapf, tensorboard }:

buildPythonPackage rec {
  pname = "basicsr";
  version = "1.4.2";

  src = fetchPypi {
    inherit pname version;
    sha256 = "11qy60qqxdxp1k0w0xsmjr65bdnxh29xkd0kk7d4r5pghxd5k6xq";
  };

  buildInputs = [ cython numpy torch ];
  propagatedBuildInputs = [
    addict
    future
    lmdb
    numpy
    opencv-python
    pillow
    pyyaml
    requests
    scikit-image
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
    description = "Open Source Image and Video Super-Resolution Toolbox";
    homepage = "https://github.com/xinntao/BasicSR";
  };
}
