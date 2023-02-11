# WARNING: This file was automatically generated. You should avoid editing it.
# If you run pynixify again, the file will be either overwritten or
# deleted, and you will lose the changes you made to it.

{ buildPythonPackage, cython, fetchPypi, filterpy, lib, numba, numpy
, opencv-python, pillow, scipy, torch, torchvision, tqdm }:

buildPythonPackage rec {
  pname = "facexlib";
  version = "0.2.5";

  src = fetchPypi {
    inherit pname version;
    sha256 = "1r378mb167k2hynrn1wsi78xbh2aw6x68i8f70nmcqsxxp20rqii";
  };

  patches = [ ./root_dir.patch ];
  buildInputs = [ cython numpy ];
  propagatedBuildInputs = [
    filterpy
    numba
    numpy
    numpy
    opencv-python
    pillow
    scipy
    torch
    torchvision
    tqdm
  ];

  # TODO FIXME
  doCheck = false;

  meta = with lib; {
    description = "Basic face library";
    homepage = "https://github.com/xinntao/facexlib";
  };
}
