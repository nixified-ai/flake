{ lib
, buildPythonPackage
, fetchPypi
, pythonOlder
, hatchling
, packaging
}:

buildPythonPackage rec {
  pname = "hatch-requirements-txt";
  version = "0.2.0";
  disabled = pythonOlder "3.6.1";
  format = "pyproject";

  # We use the Pypi release, as it provides prebuild webui assets,
  # and its releases are also more frequent than github tags
  src = fetchPypi {
    pname = "hatch_requirements_txt";
    inherit version;
    sha256 = "sha256-I8z34vvPK7Mg9+Xg2nMgNcgeh5QFB0LV2j0iwzA1QGc=";
  };

  nativeBuildInputs = [
  ];
  propagatedBuildInputs = [
    hatchling
    packaging
  ];

  # TODO FIXME
  doCheck = false;

  meta = with lib; {
    homepage = "https://github.com/repo-helper/hatch-requirements-txt";
    description = "Hatchling plugin to read project dependencies from requirements.txt";
  };
}
