{ buildPythonPackage, fetchFromGitHub, lib, stdenv, darwin, cmake, ninja, poetry-core, scikit-build, setuptools, typing-extensions }:
let
  osSpecific = with darwin.apple_sdk.frameworks; if stdenv.isDarwin then [ Accelerate ] else [ ];
  llama-cpp-pin = fetchFromGitHub {
    owner = "ggerganov";
    repo = "llama.cpp";
    rev = "54bb60e26858be251a0eb3cb70f80322aff804a0";
    hash = "sha256-a+MQ/CUQd+aTQy04P2re5LK4fdLrWRepbBYSv9wXvVE=";
  };
in
buildPythonPackage rec {
  pname = "llama-cpp-python";
  version = "0.1.38";

  format = "pyproject";
  src = fetchFromGitHub {
    owner = "abetlen";
    repo = pname;
    rev = "v${version}";
    hash = "sha256-/Ykndsp6puFxa+FSHNln9M2frS7/sMMBJSNJ/mU/CSI=";
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
    poetry-core
    scikit-build
    setuptools
  ];

  propagatedBuildInputs = [
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
