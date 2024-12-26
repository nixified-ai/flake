{ lib
, fetchFromGitHub
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
, torch
}:

let
  pname = "safetensors";
  version = "0.3.3";
  src = fetchFromGitHub {
    repo = pname;
    owner = "huggingface";
    rev = "v${version}";
    hash = "sha256-U+indMoLFN6vMZkJTWFG08lsdXuK5gOfgaHmUVl6DPk=";
  };
in

buildPythonPackage rec {
  inherit pname version src;
  format = "pyproject";
  postPatch = "cd bindings/python";

  cargoDeps = rustPlatform.fetchCargoTarball {
    inherit src;
    postPatch = "cd bindings/python";
    name = "${pname}-${version}";
    hash = "sha256-qiJtiPpNs7wycOyzef34OgXxUGMaKZIXEdqomxtmUD0=";
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
