{ lib, buildPythonPackage, fetchPypi }:

buildPythonPackage rec {
  pname = "attributedict";
  version = "0.3.0";

  src = fetchPypi {
    inherit pname version;
    # nix-prefetch fetchPypi --pname attributedict --version 0.3.0
    sha256 = "mDw6tSyhgXeFo80i99l16tSxy+e8RmxewdRyjq55HHo=";
  };

  propagatedBuildInputs = [ ];

  meta = with lib; {
    description = "A dictionary object with attributes support.";
    homepage = "https://github.com/grimen/python-attributedict";
    license = licenses.mit;
    maintainers = with maintainers; [ ]; # Add your maintainer information
  };
}
