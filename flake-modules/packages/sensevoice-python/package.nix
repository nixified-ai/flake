{
  buildPythonPackage,
  fetchFromGitHub,
  huggingface-hub,
  numpy,
  onnxruntime,
  protobuf,
  sentencepiece,
  soundfile,
  kaldi-native-fbank,
  bat,
}:
buildPythonPackage {
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
