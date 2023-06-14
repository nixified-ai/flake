{ buildPythonPackage, fetchPypi, setuptools, python-socketio, fastapi }:

buildPythonPackage rec {
  pname = "fastapi-socketio";
  version = "0.0.9";
  format = "pyproject";

  src = fetchPypi {
    inherit pname version;
    sha256 = "sha256-jHOqlP4b8cmWT/iSM6a6Uu7uw6yLneACTZ2CsR5GveU=";
  };

  propagatedBuildInputs = [
    setuptools
    python-socketio
    fastapi
  ];

  doCheck = false;

  meta = {
    description = "Easly integrate socket.io with your FastAPI app.";
    homepage = "https://github.com/pyropy/fastapi-socketio";
  };
}
