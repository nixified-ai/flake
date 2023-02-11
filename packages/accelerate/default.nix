# WARNING: This file was automatically generated. You should avoid editing it.
# If you run pynixify again, the file will be either overwritten or
# deleted, and you will lose the changes you made to it.

{ buildPythonPackage, fetchPypi, lib, numpy, packaging, psutil, pyyaml, torch }:

buildPythonPackage rec {
  pname = "accelerate";
  version = "0.13.1";

  src = fetchPypi {
    inherit pname version;
    sha256 = "1dk82s80rq8xp3v4hr9a27vgj9k3gy9yssp7ww7i3c0vc07gx2cv";
  };

  propagatedBuildInputs = [ numpy packaging psutil pyyaml torch ];

  # TODO FIXME
  doCheck = false;

  meta = with lib; {
    description = "Accelerate";
    homepage = "https://github.com/huggingface/accelerate";
  };
}
