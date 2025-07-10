{
  buildPythonPackage,
  fetchFromGitHub,
}:
buildPythonPackage
rec {
  pname = "SenseVoice-python";
  version = "43f6cf1";
  format = "pyproject";
  src = fetchFromGitHub {
    owner = "shadowcz007";
    repo = "SenseVoice-python";
    rev = "43f6cf1531e7e4a7d7507d37fbc9b0fb169166ab";
    hash = "sha256-ybKnhTyIE12lf5O9u5fbPHScOp8CatHBpLJLju8XRuY=";
  };
}
