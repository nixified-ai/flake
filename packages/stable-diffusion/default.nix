{
  buildPythonPackage
, pythonRelaxDepsHook
, fetchFromGitHub

, torch
, torchvision
, numpy

, albumentations
, opencv4
, pudb
, imageio
, imageio-ffmpeg
, pytorch-lightning
, omegaconf
, test-tube
, streamlit
, einops
, taming-transformers-rom1504
, torch-fidelity
, torchmetrics
, transformers
, kornia
, k-diffusion
}:
buildPythonPackage rec {
  pname = "stable-diffusion";
  version = "2022-08-22";

  src = fetchFromGitHub {
    owner = "CompVis";
    repo = pname;
    rev = "69ae4b35e0a0f6ee1af8bb9a5d0016ccb27e36dc";
    sha256 = "sha256-3YkSUATD/73nJFm4os3ZyNU8koabGB/6iR0XbTUQmVY=";
  };

  nativeBuildInputs = [ pythonRelaxDepsHook ];
  pythonRelaxDeps = [
    "transformers"
  ];

  propagatedBuildInputs = [
    torch
    torchvision
    numpy

    albumentations
    opencv4
    pudb
    imageio
    imageio-ffmpeg
    pytorch-lightning
    omegaconf
    test-tube
    streamlit
    einops
    taming-transformers-rom1504
    torch-fidelity
    torchmetrics
    transformers
    kornia
    k-diffusion
  ];

  doCheck = false;
}
