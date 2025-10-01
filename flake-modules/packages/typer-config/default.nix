{
  buildPythonPackage,
  fetchPypi,
  typer,
  poetry-core,
}:
buildPythonPackage rec {
  pname = "typer_config";
  version = "1.4.2";
  format = "pyproject";
  src = fetchPypi {
    inherit pname version;
    hash = "sha256-ad/8DgYJW1d1S/6fs+TK8oq5wsQw2t5kM7DKEoUQ9gA=";
  };

  propagatedBuildInputs = [ typer ];

  buildInputs = [ poetry-core ];
}
