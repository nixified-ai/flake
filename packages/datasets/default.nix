{ lib
, buildPythonPackage
, fetchPypi
}:

buildPythonPackage rec {
  pname = "datasets";
  version = "2.14.6";
  format = "setuptools";

  src = fetchPypi {
    inherit pname version;
    sha256 = "sha256-l+u6zo7HrxFDSofRIVN5kn+P7ivqssSmdAA3Vuz+kgw=";
  };

  doCheck = false;

  meta = with lib; {
    description = "";
    homepage = "";
    license = licenses.asl20;
    maintainers = with maintainers; [ ];
  };
}
