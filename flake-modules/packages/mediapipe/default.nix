{ lib
, fetchurl
, buildPythonPackage
, protobuf
, numpy
, opencv4
, attrs
, matplotlib
, autoPatchelfHook
}:

buildPythonPackage {
  pname = "mediapipe";
  version = "0.10.8";
  format = "wheel";

  src = fetchurl {
    url = "https://files.pythonhosted.org/packages/b9/9c/91262b3c43a4938fce2349ad0acd7463770604f4d964dfaabbd070761bb9/mediapipe-0.10.8-cp311-cp311-manylinux_2_17_x86_64.manylinux2014_x86_64.whl";
    sha256 = "sha256-K5u5w895+ISdtDwRk7XmIAp0BsjLVsBtyf8w2LCztbs=";
  };

  propagatedBuildInputs = [ protobuf numpy opencv4 matplotlib attrs ];

  nativeBuildInputs = [ autoPatchelfHook ];

  pythonImportsCheck = [ "mediapipe" ];

  meta = with lib; {
    description = "Cross-platform, customizable ML solutions for live and streaming media";
    homepage = "https://github.com/google/mediapipe/releases/tag/v0.10.8";
    license = licenses.asl20;
    maintainers = with maintainers; [ ];
  };
}
