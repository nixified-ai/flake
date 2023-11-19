{ buildPythonPackage, fetchFromGitHub, lib, stdenv, darwin, cmake, ninja, pathspec, poetry-core, pyproject-metadata, scikit-build-core, setuptools, diskcache, numpy, typing-extensions }:
let
  inherit (stdenv) isDarwin;
  osSpecific = with darwin.apple_sdk.frameworks; if isDarwin then [ Accelerate CoreGraphics CoreVideo ] else [ ];
  llama-cpp-pin = fetchFromGitHub {
    owner = "ggerganov";
    repo = "llama.cpp";
    rev = "a98b1633d5a94d0aa84c7c16e1f8df5ac21fc850";
    hash = "sha256-HNwyPJXsUL41zLA+90Yu7kCpihW0HBOeW2jDs8sw7qs=";
  };
in
buildPythonPackage rec {
  pname = "llama-cpp-python";
  version = "0.2.7";

  format = "pyproject";
  src = fetchFromGitHub {
    owner = "abetlen";
    repo = pname;
    rev = "refs/tags/v${version}";
    hash = "sha256-jL2jVTKwmTx6pSnoN5n4NtQ3hs3weXiQTKFQdjL172U=";
  };

  preConfigure = ''
    cp -r ${llama-cpp-pin}/. ./vendor/llama.cpp
    chmod -R +w ./vendor/llama.cpp
  '';
  preBuild = ''
    cd ..
  '';
  buildInputs = osSpecific;

  nativeBuildInputs = [
    cmake
    ninja
    pathspec
    poetry-core
    pyproject-metadata
    scikit-build-core
    setuptools
  ];

  propagatedBuildInputs = [
    diskcache
    numpy
    typing-extensions
  ];

  pythonImportsCheck = [ "llama_cpp" ];

  meta = with lib; {
    description = "A Python wrapper for llama.cpp";
    homepage = "https://github.com/abetlen/llama-cpp-python";
    license = licenses.mit;
    maintainers = with maintainers; [ jpetrucciani ];
  };
}
