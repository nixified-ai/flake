# WARNING: This file was not automatically generated.
# If you run pynixify, the file will be either overwritten or
# deleted, and you will lose the changes you made to it.

{ lib
, stdenv
, aipython3
, autoPatchelfHook
, oneDNN
, onnxruntime
, re2
}:

# onnxruntime requires an older protobuf.
# Doing an override in protobuf in the python-packages set
# can give you a functioning Python package but note not
# all Python packages will be compatible then.
#
# Because protobuf is not always needed we remove it
# as a runtime dependency from our wheel.
#
# We do include here the non-Python protobuf so the shared libs
# link correctly. If you do also want to include the Python
# protobuf, you can add it to your Python env, but be aware
# the version likely mismatches with what is used here.

aipython3.buildPythonPackage {
  inherit (onnxruntime) version;
  pname = "onnxruntime-python";
  format = "wheel";
  src = onnxruntime.dist;

  unpackPhase = ''
    cp -r $src dist
    chmod +w dist
  '';

  nativeBuildInputs = [
    aipython3.pythonRelaxDepsHook
  ] ++ lib.optionals stdenv.isLinux [
    autoPatchelfHook
  ];

  # This project requires fairly large dependencies such as sympy which we really don't always need.
  pythonRemoveDeps = [
    "flatbuffers"
    "protobuf"
    "sympy"
  ];

  # Libraries are not linked correctly.
  buildInputs = [
    oneDNN
    re2
    onnxruntime.protobuf
  ];

  propagatedBuildInputs = with aipython3; [
    coloredlogs
    flatbuffers
    numpy
    packaging
    protobuf
    sympy
  ];

  meta = onnxruntime.meta // { maintainers = with lib.maintainers; [ fridh ]; };
}
