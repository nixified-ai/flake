{ lib
, buildPythonPackage
, fetchPypi
}:

buildPythonPackage rec {
  pname = "speechrecognition";
  version = "3.10.4";
  format = "setuptools";

  src = fetchPypi {
    inherit pname version;
    sha256 = "sha256-mGuvz2HxRiXC886mpHGDjt03ntaK7te488D7QeIfESU=";
  };

  # Wants to run tests using a real audio device
  doCheck = false;

  meta = with lib; {
    description = "";
    homepage = "";
    license = licenses.bsd3;
    maintainers = with maintainers; [ ];
  };
}
