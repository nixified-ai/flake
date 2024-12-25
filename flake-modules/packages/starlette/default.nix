{ lib
, stdenv
, buildPythonPackage
, fetchFromGitHub
, fetchpatch
, aiofiles
, anyio
, contextlib2
, hatchling
, itsdangerous
, jinja2
, python-multipart
, pyyaml
, requests
, aiosqlite
, pytestCheckHook
, pythonOlder
, trio
, typing-extensions
}:

buildPythonPackage rec {
  pname = "starlette";
  version = "0.22.0";
  format = "pyproject";

  disabled = pythonOlder "3.6";

  src = fetchFromGitHub {
    owner = "encode";
    repo = pname;
    rev = "refs/tags/${version}";
    hash = "sha256-vyGLNQMCWu3zGFF7jRuozVLCqwR1zWBWuYTIDRBncHk=";
  };

  postPatch = ''
    # remove coverage arguments to pytest
    sed -i '/--cov/d' setup.cfg
  '';

  propagatedBuildInputs = [
    aiofiles
    anyio
    hatchling
    itsdangerous
    jinja2
    python-multipart
    pyyaml
    requests
  ] ++ lib.optionals (pythonOlder "3.8") [
    typing-extensions
  ] ++ lib.optionals (pythonOlder "3.7") [
    contextlib2
  ];

  doCheck = false;

  checkInputs = [
    aiosqlite
    pytestCheckHook
    trio
    typing-extensions
  ];

  disabledTests = [
    # asserts fail due to inclusion of br in Accept-Encoding
    "test_websocket_headers"
    "test_request_headers"
  ];

  pythonImportsCheck = [
    "starlette"
  ];

  meta = with lib; {
    homepage = "https://www.starlette.io/";
    description = "The little ASGI framework that shines";
    license = licenses.bsd3;
    maintainers = with maintainers; [ wd15 ];
  };
}

