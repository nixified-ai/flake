{ lib, buildPythonPackage, fetchPypi }:

buildPythonPackage rec {
  pname = "attributedict";
  version = "0.3.0";

  src = fetchPypi {
    inherit pname version;
    # nix-prefetch-url --unpack https://pypi.io/packages/source/a/attributedict/attributedict-0.3.0.tar.gz
    sha256 = "1hgbaj0p7ya4cb8w967j3qa7lzh3yp8b1m3yjyjgax3byybf3cgv";
  };

  propagatedBuildInputs = [ ];

  meta = with lib; {
    description = "A dictionary object with attributes support.";
    homepage = "https://github.com/grimen/python-attributedict";
    license = licenses.mit;
    maintainers = with maintainers; [ ]; # Add your maintainer information
  };
}
