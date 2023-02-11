# WARNING: This file was automatically generated. You should avoid editing it.
# If you run pynixify again, the file will be either overwritten or
# deleted, and you will lose the changes you made to it.

{ buildPythonPackage, fetchFromGitHub, lib, numpy, pillow, requests, scipy, torch, pythonRelaxDepsHook
, torchvision, tqdm }:

buildPythonPackage rec {
  pname = "clean-fid";
  version = "0.1.31";

  src = fetchFromGitHub {
    owner = "GaParmar";
    repo = "clean-fid";
    rev = "e74252caf7120d4d0b16d3ee0d64f7a526f995a2"; #no tags or releases in repo
    sha256 = "sha256-/aw0W9htarpuCatTwmT4hEq4X+adohAQBIFwViPu/e8=";
  };
  #src = lib.cleanSource ../../..;

  nativeBuildInputs = [ pythonRelaxDepsHook ];
  pythonRelaxDeps = [ "requests" ];

  propagatedBuildInputs =
    [ torch torchvision numpy scipy tqdm pillow requests ];

  # TODO FIXME
  doCheck = false;

  meta = with lib; {
    description =
      "FID calculation in PyTorch with proper image resizing and quantization steps";
    homepage = "https://github.com/GaParmar/clean-fid";
  };
}
