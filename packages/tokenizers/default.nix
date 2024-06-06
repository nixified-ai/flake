{ lib
, buildPythonPackage
, fetchurl
}:

buildPythonPackage rec {
  pname = "tokenizers";
  version = "0.14.1";
  format = "wheel";

  src = fetchurl {
    url = "https://files.pythonhosted.org/packages/a7/7b/c1f643eb086b6c5c33eef0c3752e37624bd23e4cbc9f1332748f1c6252d1/tokenizers-0.14.1-cp310-cp310-manylinux_2_17_x86_64.manylinux2014_x86_64.whl";
    sha256 = "sha256-YP7DgHeNdcu0kvFMqXTxHze0HVPAV7nIuiEzFbhuH4Q=";
  };

  doCheck = false;

  meta = with lib; {
    description = "";
    homepage = "";
    license = licenses.asl20;
    maintainers = with maintainers; [ ];
  };
}
