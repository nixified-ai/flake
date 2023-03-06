{ lib, python3Packages }:

python3Packages.buildPythonPackage rec {
  pname = "apispec-webframeworks";
  version = "0.5.2";
  disabled = python3Packages.pythonOlder "3.6";

  src = python3Packages.fetchPypi {
    inherit pname version;
    hash = "sha256-DbNbJnkUs/jFYqygJhlX28tBdvJV6swiUgJ3AQgY3PM=";
  };

  propagatedBuildInputs = with python3Packages; [
    apispec
    packaging
    pyyaml
  ];

  nativeCheckInputs = with python3Packages; [
    pytestCheckHook
    mock
    flask
    tornado
    bottle
  ];

  doCheck = false;

  pythonImportsCheck = [ "apispec_webframeworks" ];

  meta = with lib; {
    description = "apispec plugin for integrating with various web frameworks";
    homepage = "https://github.com/marshmallow-code/apispec-webframeworks";
    license = licenses.mit;
    maintainers = [ maintainers.sikmir ];
  };
}
