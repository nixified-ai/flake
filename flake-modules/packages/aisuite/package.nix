{
  buildPythonPackage,
  fetchFromGitHub,
  poetry-core,
  httpx,
}:
buildPythonPackage rec {
  pname = "aisuite";
  version = "0.1.7";
  format = "pyproject";
  src = fetchFromGitHub {
    owner = "andrewyng";
    repo = "aisuite";
    rev = "v${version}";
    hash = "sha256-gV42VTnKUQtDlEY7LRZ75N08EnSmhlTxu0ySgZpzYwY=";
  };

  buildInputs = [ poetry-core ];

  postPatch = ''
    substituteInPlace pyproject.toml \
      --replace-fail 'httpx = "~0.27.0"' 'httpx = "*"'
  '';

  propagatedBuildInputs = [ httpx ];
}
