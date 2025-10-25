{
  buildPythonPackage,
  fetchPypi,
  poetry-core,
  httpx,
  pydantic,
  pydantic-core,
  cachetools,
  pyjwt,
}:
buildPythonPackage rec {
  pname = "zhipuai";
  version = "2.1.5.20250611";
  format = "pyproject";
  src = fetchPypi {
    inherit pname version;
    hash = "sha256-047L7cG9zng+sUEo7oYZqY2TvujAB+QO/DuwMCIwdJ0=";
  };
  postPatch = ''
    substituteInPlace pyproject.toml \
        --replace '"poetry-plugin-pypi-mirror==0.4.2"' ""
    substituteInPlace pyproject.toml \
        --replace 'pyjwt = "~=2.8.0"' 'pyjwt = "*"'
  '';

  buildInputs = [ poetry-core ];

  propagatedBuildInputs = [
    httpx
    pydantic
    pydantic-core
    cachetools
    pyjwt

    # pytest
    # pytest-cov
    # pytest-dotenv
    # duckdb-engine
    # pytest-watcher = "^0.2.6"
    # freezegun = "^1.2.2"
    # responses = "^0.22.0"
    # pytest-asyncio = { version = "^0.23.2", python = "^3.8" }
    # lark = "^1.1.5"
    # pytest-mock = "^3.10.0"
    # pytest-socket = { version = "^0.6.0", python = ">=3.8.1,<3.9.7 || >3.9.7,<4.0" }
    # syrupy = { version = "^4.0.2", python = ">=3.8.1,<3.9.7 || >3.9.7,<4.0" }
    # requests-mock = "^1.11.0"
    # respx = "0.21.1"
    #
    #
    # [tool.poetry.group.lint]
    # optional = true
    #
    # [tool.poetry.group.lint.dependencies]
    # ruff = "^0.1.5"
    #
    # [tool.poetry.extras]
    # cli = ["typer"]
  ];
}
