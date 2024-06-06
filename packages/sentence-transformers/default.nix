{ lib
, buildPythonPackage
, fetchPypi
}:

buildPythonPackage rec {
  pname = "sentence-transformers";
  version = "2.2.2";
  format = "setuptools";

  src = fetchPypi {
    inherit pname version;
    sha256 = "sha256-28YBY7J94hB2yaMNJLW3tvoFFB1ozyVT+pp3v3mikTY=";
  };

  doCheck = false;

  meta = with lib; {
    description = "";
    homepage = "";
    license = licenses.asl20;
    maintainers = with maintainers; [ ];
  };
}
