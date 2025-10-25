{
  buildPythonPackage,
  cmake,
  fetchPypi,
  gtest,
  kissfft,
  lib,
  pybind11,
  setuptools,
  torch,
  wheel,
}:
buildPythonPackage rec {
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
}
