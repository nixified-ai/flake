{ lib
, fetchPypi
, runCommand
, rustPlatform
, cargo
, rustc
, buildPythonPackage
, setuptools
, setuptools-rust
, wheel
, black
, click
, huggingface-hub
, isort
, jax
, numpy
, pytest
, pytest-benchmark
, tensorflow
, torch
}:

let

  pname = "safetensors";
  version = "0.2.8";

  patchedSrc = runCommand "patched-src" {
    src = fetchPypi {
      inherit pname version;
      hash = "sha256-JyCyCmo4x5ncp5vXbK7qwvffWFqdT31Z+n4o7/nMsn8=";
    };
  } ''
    unpackPhase
    cp ${./Cargo.lock} $sourceRoot/Cargo.lock
    cp -r $sourceRoot $out
  '';
in

buildPythonPackage {
  inherit pname version;
  format = "pyproject";
  src = patchedSrc;

  cargoDeps = rustPlatform.fetchCargoTarball {
    src = patchedSrc;
    name = "${pname}-${version}";
    hash = "sha256-IZKaw4NquK/BbIv1xkMFgNR20vve4H6Re76mvxtcNUA=";
  };

  nativeBuildInputs = [
    setuptools
    setuptools-rust
    wheel
    rustPlatform.cargoSetupHook
    cargo
    rustc
  ];

  propagatedBuildInputs = [
    black
    click
#    flake
#    flax
#    h
    huggingface-hub
    isort
    jax
    numpy
    pytest
    pytest-benchmark
    setuptools-rust
    tensorflow
    torch
  ];

  pythonImportsCheck = [ "safetensors" ];

  meta = with lib; {
    description = "Fast and Safe Tensor serialization";
    homepage = "https://pypi.org/project/safetensors/";
    license = with licenses; [ ];
    maintainers = with maintainers; [ ];
  };
}
