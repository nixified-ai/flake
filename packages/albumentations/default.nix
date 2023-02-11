# WARNING: This file was automatically generated. You should avoid editing it.
# If you run pynixify again, the file will be either overwritten or
# deleted, and you will lose the changes you made to it.

{ buildPythonPackage, fetchPypi, lib, numpy, opencv-python-headless, pyyaml
, qudida, scikit-image, scipy }:

buildPythonPackage rec {
  pname = "albumentations";
  version = "1.3.0";

  src = fetchPypi {
    inherit pname version;
    sha256 = "1vbvyd0np69wz9q1nk3kf13y00cqq650wmd5y8a372f869lg66my";
  };

  propagatedBuildInputs =
    [ numpy scipy scikit-image pyyaml qudida opencv-python-headless ];

  # TODO FIXME
  doCheck = false;

  meta = with lib; {
    description =
      "Fast image augmentation library and easy to use wrapper around other libraries";
    homepage = "https://github.com/albumentations-team/albumentations";
  };
}
