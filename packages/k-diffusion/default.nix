# WARNING: This file was automatically generated. You should avoid editing it.
# If you run pynixify again, the file will be either overwritten or
# deleted, and you will lose the changes you made to it.

{ accelerate, buildPythonPackage, clip-anytorch, einops, fetchPypi, jsonmerge
, kornia, lib, pillow, resize-right, scikit-image, scipy, torch, torchdiffeq
, torchvision, tqdm, wandb, clean-fid }:

buildPythonPackage rec {
  pname = "k-diffusion";
  version = "0.0.9";

  src = fetchPypi {
    inherit pname version;
    sha256 = "02j7hkhdh57bkvc75xygj50a64dzdi44d1gsw4wjmvp9f7pllpfa";
  };

  propagatedBuildInputs = [
    accelerate
    clip-anytorch
    einops
    jsonmerge
    kornia
    pillow
    resize-right
    scikit-image
    scipy
    torch
    torchdiffeq
    torchvision
    tqdm
    wandb
    clean-fid
  ];

  # TODO FIXME
  doCheck = false;

  meta = with lib; { };
}
