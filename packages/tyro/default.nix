{ buildPythonPackage
, lib
, fetchPypi
, poetry-core
, frozendict
, rich
, typing-extensions
, shtab
, docstring-parser
, pyyaml
}:

buildPythonPackage rec {
  pname = "tyro";
  version = "0.5.3";

  format = "pyproject";

  src = fetchPypi {
    inherit pname version;
    sha256 = "sha256-ygdNkRr4bjDDHioXoMWPZ1c0IamIkqGyvAuvJx3Bhis=";
  };

  propagatedBuildInputs = [ poetry-core frozendict rich typing-extensions shtab docstring-parser pyyaml ];
}
