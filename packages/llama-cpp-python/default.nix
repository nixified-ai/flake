{ buildPythonPackage
, fetchFromGitHub
, lib
, cudaPackages
, cmake
, ninja
, pathspec
, pyproject-metadata
, scikit-build-core
, diskcache
, numpy
, typing-extensions
}:
buildPythonPackage rec {
  pname = "llama-cpp-python";
  version = "0.2.7";

  format = "pyproject";
  src = fetchFromGitHub {
    owner = "abetlen";
    repo = pname;
    rev = "refs/tags/v${version}";
    hash = "sha256-2uPWH8ik/YznJTNBCopz58YjDJ7i1l9hgp8t0Nwjm5Q=";
    fetchSubmodules = true;
  };

  dontUseCmakeConfigure = true;
  SKBUILD_CMAKE_ARGS = lib.strings.concatStringsSep ";" [
    "-DLLAMA_CUBLAS=on"
  ];

  buildInputs = [
    cudaPackages.cudatoolkit
  ];

  nativeBuildInputs = [
    cmake
    ninja
    pathspec
    pyproject-metadata
    scikit-build-core
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
