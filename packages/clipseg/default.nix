# WARNING: This file was automatically generated. You should avoid editing it.
# If you run pynixify again, the file will be either overwritten or
# deleted, and you will lose the changes you made to it.

{ buildPythonPackage, clip-anytorch, fetchFromGitHub, lib, matplotlib, numpy, opencv-python
, scipy, torch, torchvision }:

buildPythonPackage rec {
  pname = "clipseg";
  version = "0.0.1";

  src = fetchFromGitHub {
    owner = "invoke-ai";
    repo = "clipseg";
    rev = "master";
    sha256 = "sha256-S5RAeodqG7X6E5hnFhorR3LmfapKD9r50PqXGuc5sXE=";
    };

  propagatedBuildInputs =
    [ numpy scipy matplotlib torch torchvision opencv-python clip-anytorch ];

  # TODO FIXME
  doCheck = false;

  meta = with lib; {
    description = ''
      This repository contains the code used in the paper "Image Segmentation Using Text and Image Prompts".'';
    homepage = "https://github.com/timojl/clipseg";
  };
}
