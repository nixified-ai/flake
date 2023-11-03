{ lib
, buildPythonPackage
, fetchPypi
, cython
, numpy
, six
, dynalite-devices
, pythonOlder
, stdenv }:

buildPythonPackage rec {
  pname = "nagisa";
  version = "0.2.9";

  src = fetchPypi {
    inherit pname version;
    # nix-prefetch-url --unpack https://files.pythonhosted.org/packages/source/n/nagisa/nagisa-0.2.9.tar.gz
    sha256 = "0fh78ijd5s1fq66ib7f7cr1dykycbfzzjar2h1pznpr284lbjk7y";
  };

  buildInputs = [ cython numpy ];

  propagatedBuildInputs = [
    six
    numpy
  ];

  checkInputs = [ ];

  meta = with lib; {
    description = "A Japanese tokenizer based on recurrent neural networks";
    homepage = "https://github.com/taishi-i/nagisa";
    license = licenses.mit;
    maintainers = with maintainers; [ ];
  };
}
