{ lib
, fetchPypi
, runCommand
, rustPlatform
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
  version = "0.3.0";

  patchedSrc = runCommand "patched-src" {
    src = fetchPypi {
      inherit pname version;
      hash = "sha256-W+iy/M3GrshMnWcyGAV1/hujr8VZy+luIwHqzEXFuaY=";
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
    hash = "sha256-z6LJ4nzQ99NKy0prLvb1YpDd0VC5CqSd0nCBp61EhWE=";
  };

  nativeBuildInputs = [
    setuptools
    setuptools-rust
    wheel
    rustPlatform.cargoSetupHook
    rustPlatform.rust.cargo
    rustPlatform.rust.rustc
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
