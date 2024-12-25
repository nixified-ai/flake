# WARNING: This file was automatically generated. You should avoid editing it.
# If you run pynixify again, the file will be either overwritten or
# deleted, and you will lose the changes you made to it.

{ buildPythonPackage, fetchPypi, lib, ftfy, regex, tqdm, torch, torchvision }:

buildPythonPackage rec {
  pname = "clip-anytorch";
  version = "2.5.0";

  src = fetchPypi {
    inherit pname version;
    sha256 = "1pf8w4i6nrrz0879afbz4iar0ss82xl4mqm94lffd6c3f2gk05x3";
  };

  propagatedBuildInputs = [
    ftfy
    regex
    tqdm
    torch
    torchvision
  ];

  postUnpack = ''
    #source distribution of torch-fidelity doesn't include this file, while it's used by setup.py
    cp ${./requirements.txt} clip-anytorch-${version}/requirements.txt
    '';

  # TODO FIXME
  doCheck = false;

  meta = with lib; { };
}
