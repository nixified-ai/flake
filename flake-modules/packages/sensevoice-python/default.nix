{
  buildPythonPackage,
  fetchFromGitHub,
  fetchPypi,
  huggingface-hub,
  lib,
  numpy,
  onnxruntime,
  protobuf,
  sentencepiece,
  setuptools,
  soundfile,
  wheel,
  cmake,
  pybind11,
  torch,
  gtest,
  kissfft,
  bat,
}:
let
  # TODO: create an overlay extending python3Packages, so that this can
  # be put in seperate file and injected via args above
  kaldi-native-fbank = buildPythonPackage rec {
    pname = "kaldi-native-fbank";
    version = "1.22.3";
    pyproject = true;

    src = fetchPypi {
      inherit pname version;
      hash = "sha256-OHv4ciXGuDyTrmUu6u8bTVMZlLbjmOencYneNAZ0+a8=";
    };

    build-system = [
      setuptools
      wheel
    ];
    dontUseCmakeConfigure = true;
    postPatch = ''
      substituteInPlace cmake/cmake_extension.py \
        --replace 'DKALDI_NATIVE_FBANK_BUILD_TESTS=OFF "' \
                  "DKALDI_NATIVE_FBANK_BUILD_TESTS=OFF \
                    -DFETCHCONTENT_SOURCE_DIR_PYBIND11=${pybind11.src} \
                    -DFETCHCONTENT_SOURCE_DIR_GOOGLETEST=${gtest.src} \
                    -DFETCHCONTENT_SOURCE_DIR_KISSFFT=${kissfft.src}\""
    '';
    nativeBuildInputs = [
      cmake
      pybind11
      gtest
      kissfft
    ];

    propagatedBuildInputs = [
      torch
    ];

    pythonImportsCheck = [
      "kaldi_native_fbank"
    ];

    meta = {
      description = "";
      homepage = "https://pypi.org/project/kaldi-native-fbank/";
      license = lib.licenses.asl20;
      maintainers = with lib.maintainers; [ ];
    };
  };
in
buildPythonPackage rec {
  pname = "SenseVoice-python";
  version = "git-34e19be";
  format = "setuptools";
  src = fetchFromGitHub {
    owner = "shadowcz007";
    repo = "SenseVoice-python";
    rev = "34e19be6f369e22c53a0dd5b6c99a6476130d2a7";
    hash = "sha256-crD6IKFLu8F/dutssVMKSNwbN7GVSl7BnYKZfw1SBzc=";
  };
  propagatedBuildInputs = [
    numpy
    kaldi-native-fbank
    onnxruntime
    sentencepiece
    soundfile
    huggingface-hub
    protobuf
  ];
}
