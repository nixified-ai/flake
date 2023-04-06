{ buildPythonPackage
, fetchFromGitHub
, setuptools
, starlette
}:

buildPythonPackage rec {
  pname = "fastapi-events";
  version = "0.6.0";
  format = "pyproject";

  src = fetchFromGitHub {
    owner = "melvinkcx";
    repo = "fastapi-events";
    rev = "v${version}";
    hash = "sha256-4Hl+U48vv8WK+qCdpEIlUO/dWPfIiwJC56zXLXa51UE=";
  };

  pythonImportsCheck = [ "fastapi_events" ];

  nativeBuildInputs = [ setuptools ];

  propagatedBuildInputs = [ starlette ];
}
