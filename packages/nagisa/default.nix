{ lib
, buildPythonPackage
, fetchPypi
, cython
, numpy
, six
, dynet
, pythonOlder
, stdenv
}:

buildPythonPackage rec {
  pname = "nagisa";
  version = "0.2.9";

  src = fetchPypi {
    inherit pname version;
    sha256 = "rykmKR5+AkFigZ12n5KhnP3cm/34Fc0+aFdBLED/eOs=";
  };

  buildInputs = [ cython numpy ];

  propagatedBuildInputs = [
    six
    numpy
    dynet
  ];

  checkInputs = [ ];

  postPatch = ''
    substituteInPlace setup.py \
      --replace "if os.name == 'posix' and major == 3 and minor > 7:" "if False:"
  '';

  meta = with lib; {
    description = "A Japanese tokenizer based on recurrent neural networks";
    homepage = "https://github.com/taishi-i/nagisa";
    license = licenses.mit;
    maintainers = with maintainers; [ ];
  };
}
