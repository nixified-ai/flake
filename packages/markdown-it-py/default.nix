{ lib
, attrs
, buildPythonPackage
, fetchFromGitHub
, linkify-it-py
, mdit-py-plugins
, mdurl
, psutil
, pytest-benchmark
, pytest-regressions
, pytestCheckHook
, pythonOlder
, typing-extensions
}:

buildPythonPackage rec {
  pname = "markdown-it-py";
  version = "2.1.0";
  format = "flit";

  disabled = pythonOlder "3.6";

  src = fetchFromGitHub {
    owner = "executablebooks";
    repo = pname;
    rev = "refs/tags/v${version}";
    sha256 = "sha256-6UATJho3SuIbLktZtFcDrCTWIAh52E+n5adcgl49un0=";
  };

  postPatch = ''
    # Allow linkify-it-py v2.
    # This only affects projects that depend on 'markdown-it-py[linkify]'
    # https://github.com/executablebooks/markdown-it-py/pull/218
    substituteInPlace pyproject.toml \
      --replace "linkify-it-py~=1.0" "linkify-it-py>=1,<3"
  '';


  propagatedBuildInputs = [
    attrs
    mdurl
  ] ++ lib.optional (pythonOlder "3.8") [
    typing-extensions
  ];

  passthru.optional-dependencies = {
    linkify = [ linkify-it-py ];
    plugins = [ mdit-py-plugins ];
  };

  checkInputs = [
    linkify-it-py
    psutil
    pytest-benchmark
    pytest-regressions
    pytestCheckHook
  ];

  pythonImportsCheck = [
    "markdown_it"
  ];

  meta = with lib; {
    description = "Markdown parser in Python";
    homepage = "https://markdown-it-py.readthedocs.io/";
    changelog = "https://github.com/executablebooks/markdown-it-py/blob/${src.rev}/CHANGELOG.md";
    license = licenses.mit;
    maintainers = with maintainers; [ bhipple ];
  };
}
