{ buildPythonPackage
, fetchzip
, lib
, cmake
}:

buildPythonPackage rec {
  pname = "u3d";
  version = "1.5.1";

  format = "other";

  nativeBuildInputs = [ cmake ];

  src = fetchzip {
    url = "https://www.meshlab.net/data/libs/u3d-1.5.1.zip";
    sha256 = "sha256-2MlhGmMsECjJIamXiarHb8MV8DxSxXo/Z+aB4ZBBbJA=";
  };
}
