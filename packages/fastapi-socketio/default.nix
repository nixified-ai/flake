{ buildPythonPackage
, fetchFromGitHub
, setuptools
, python-socketio
, fastapi
}:

buildPythonPackage rec {
  pname = "fastapi-socketio";
  version = "0.0.9";
  format = "pyproject";

  src = fetchFromGitHub {
    owner = "pyropy";
    repo = "fastapi-socketio";
    rev = "${version}";
    hash = "sha256-Ft46PO66Q2Uu6UVPqsolmWyLfL2IGN6AfV+zTgPHhdA=";
  };

  pythonImportsCheck = [ "fastapi_socketio" ];

  nativeBuildInputs = [ setuptools ];

  propagatedBuildInputs = [ python-socketio fastapi ];
}
