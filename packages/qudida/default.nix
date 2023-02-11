# WARNING: This file was automatically generated. You should avoid editing it.
# If you run pynixify again, the file will be either overwritten or
# deleted, and you will lose the changes you made to it.

{ buildPythonPackage, fetchPypi, lib, numpy, opencv-python-headless
, scikit-learn, typing-extensions }:

buildPythonPackage rec {
  pname = "qudida";
  version = "0.0.4";

  src = fetchPypi {
    inherit pname version;
    sha256 = "1j4cl5dxg07p2dggv18z6rmvgps1zzxmlmiy0ah9l35bhwl8w6fv";
  };

  propagatedBuildInputs =
    [ numpy scikit-learn typing-extensions opencv-python-headless ];

  # TODO FIXME
  doCheck = false;

  meta = with lib; {
    description = "QUick and DIrty Domain Adaptation";
    homepage = "https://github.com/arsenyinfo/qudida";
  };
}
