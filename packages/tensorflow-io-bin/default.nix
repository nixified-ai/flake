{ stdenv
, lib
, fetchurl
, buildPythonPackage
, wheel
, zlib
, python
, keras
, tensorflow
, tensorlow-io-gcs-filesystem ? null
, enableGcsFilesystem ? tensorlow-io-gcs-filesystem != null
}:

let
  version = "0.28.0";
  pname = "tensorflow-io";
  cudaSupport = lib.hasSuffix "-gpu" tensorflow.pname;

  packages = {
    /*linux_py_37 = {
      url = "https://storage.googleapis.com/tensorflow/linux/cpu/tensorflow_cpu-2.9.1-cp37-cp37m-manylinux_2_17_x86_64.manylinux2014_x86_64.whl";
      sha256 = lib.fakeHash;
    };
    linux_py_38 = {
      url = "https://storage.googleapis.com/tensorflow/linux/cpu/tensorflow_cpu-2.9.1-cp38-cp38-manylinux_2_17_x86_64.manylinux2014_x86_64.whl";
      sha256 = lib.fakeHash;
    };*/
    linux_py_39 = {
      url = "https://files.pythonhosted.org/packages/91/c8/1ebae5d5583cbe3606d4021e400789ceb0ec9f05169fe6f5a26aa499b867/tensorflow_io-0.28.0-cp39-cp39-manylinux_2_12_x86_64.manylinux2010_x86_64.whl";
      sha256 = "0000000000000000000000000000000000000000000000000009";
    };
    linux_py_310 = {
      url = "https://files.pythonhosted.org/packages/d8/39/963bccfbb8f36722a52f2de211ec82f912fb1ddb7a821ccace3739492fe4/tensorflow_io-0.28.0-cp310-cp310-manylinux_2_12_x86_64.manylinux2010_x86_64.whl";
      sha256 = "sha256-Pgu34meOi3JvJREGg0jzUswT5+MJFFwcVfNHmiJ2yTc=";
    };
    linux_py_311 = {
      url = "https://files.pythonhosted.org/packages/10/e1/0d47af2822777c0ce71539edcb065aca17355b9c276ce95355eedb234c87/tensorflow_io-0.28.0-cp311-cp311-manylinux_2_12_x86_64.manylinux2010_x86_64.whl";
      sha256 = lib.fakeHash;
    };
  };
in buildPythonPackage {
  pname = "tensorflow-io";
  inherit version;
  format = "wheel";

  src = let
    pyVerNoDot = lib.strings.stringAsChars (x: if x == "." then "" else x) python.pythonVersion;
    platform = if stdenv.isDarwin then "mac" else "linux";
    key = "${platform}_py_${pyVerNoDot}";
  in fetchurl packages.${key};

  propagatedBuildInputs = [
    tensorflow
    keras
  ] ++ lib.optional (enableGcsFilesystem) tensorlow-io-gcs-filesystem;

  nativeBuildInputs = [ wheel ];

  inherit enableGcsFilesystem;
  preConfigure = ''
    unset SOURCE_DATE_EPOCH

    # Make sure that dist and the wheel file are writable.
    chmod u+rwx -R ./dist

    pushd dist

    orig_name="$(echo ./*.whl)"
    wheel unpack --dest unpacked ./*.whl
    rm ./*.whl

    pushd unpacked/tensorflow_io*
    if [[ -z ''${enableGcsFilesystem-} ]]; then
      sed -i *.dist-info/METADATA \
        -e "/Requires-Dist: tensorflow-io-gcs-filesystem/d"
    fi
    popd

    wheel pack ./unpacked/tensorflow_io*
    mv *.whl $orig_name # avoid changes to the _os_arch.whl suffix

    popd
  '';

  pythonImportsCheck = [
    "tensorflow_io"
  ];

  passthru = {
    inherit tensorflow;
  };
}
