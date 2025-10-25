{
  lib,
  buildPythonPackage,
  fetchFromGitHub,
  setuptools,
  wheel,
  torch,
  torchvision,
}:

buildPythonPackage rec {
  pname = "segment-anything";
  version = "unstable-2024-09-18";
  pyproject = true;

  src = fetchFromGitHub {
    owner = "facebookresearch";
    repo = "segment-anything";
    rev = "dca509fe793f601edb92606367a655c15ac00fdf";
    hash = "sha256-28XHhv/hffVIpbxJKU8wfPvDB63l93Z6r9j1vBOz/P0=";
  };

  propagatedBuildInputs = [
    torch
    torchvision
  ];

  build-system = [
    setuptools
    wheel
  ];

  pythonImportsCheck = [
    "segment_anything"
  ];

  meta = {
    description = "The repository provides code for running inference with the SegmentAnything Model (SAM), links for downloading the trained model checkpoints, and example notebooks that show how to use the model";
    homepage = "https://github.com/facebookresearch/segment-anything";
    license = lib.licenses.asl20;
  };
}
