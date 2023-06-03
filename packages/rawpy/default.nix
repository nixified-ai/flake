{ buildPythonPackage
, fetchFromGitHub
, lib
, numpy
, cython
, libraw
, runCommand
, pkg-config
, scikitimage
}:

buildPythonPackage rec {
  pname = "rawpy";
  version = "0.18.1";

  src = fetchFromGitHub {
    owner = "letmaik";
    repo = "rawpy";
    rev = "refs/tags/v${version}";
    sha256 = "sha256-ErQSVtv+pxKIgqCPrh74PbuWv4BKwqhLlBxtljmTCFM=";
  };

  propagatedBuildInputs = [ numpy ];

  checkInputs = [ scikitimage ];

  nativeBuildInputs = [ cython pkg-config ];

  buildInputs = [
    libraw
    # (runCommand "libraw-headers" {} ''
    #   mkdir $out
    #   ln -s ${libraw.dev}/include/libraw $out/include
    # '')
  ];

  pythonImportsCheck = [ "rawpy" ];
}
