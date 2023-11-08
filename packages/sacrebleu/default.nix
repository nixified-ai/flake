{ lib
, buildPythonPackage
, fetchFromGitHub
, typing
, portalocker
#, mecab-python3
#, ipadic
, pythonOlder
}:

let
  pname = "sacrebleu";
  version = "1.5.0";
in
buildPythonPackage rec {
  inherit pname version;
  format = "setuptools";

  src = fetchFromGitHub {
    owner = "mjpost";
    repo = pname;
    rev = "v${version}";
    # nix-prefetch-git --url https://github.com/mjpost/sacrebleu --rev v1.5.0
    hash = "sha256-ISFPYa+lHdmPA+aTpGMiqp7frb+XEIzDHyzEjmGlXik=";
  };

  nativeBuildInputs = [ ];

  propagatedBuildInputs = [
    portalocker
  ] ++ lib.optional (pythonOlder "3.5") typing ++ [
    # Extras_require dependencies for 'ja' support
    # mecab-python3
    # ipadic
  ];

  checkInputs = [ ];

  pythonImportsCheck = [ "sacrebleu" ];

  # Add any necessary configurations for the check phase if applicable

  meta = with lib; {
    description = "Hassle-free computation of shareable, comparable, and reproducible BLEU, chrF, and TER scores";
    homepage = "https://github.com/mjpost/sacrebleu";
    license = licenses.asl20;
    maintainers = with maintainers; [ ];
  };
}
