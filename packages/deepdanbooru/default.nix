{ buildPythonPackage
, fetchFromGitHub
, click
, numpy
, scikit-image
, requests
, six
, tensorflow
, tensorflow-io
}: buildPythonPackage rec {
  pname = "deepdanbooru";
  version = "2022-10-25";
  src = fetchFromGitHub {
    owner = "KichangKim";
    repo = "DeepDanbooru";
    rev = "c48689a85dde0e4a852c1691a7d746abe242e283";
    sha256 = "sha256-IPbh7pEJhn1j1SkCLo0l8955pCFKFn+vPFPtfgW4Zog=";
  };
  propagatedBuildInputs = [
    click numpy scikit-image requests six
    tensorflow-io tensorflow-io.tensorflow or tensorflow
  ];
  doCheck = false;
}
