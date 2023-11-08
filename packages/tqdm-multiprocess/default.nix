{ lib, buildPythonPackage, fetchPypi, tqdm, colorama, twine }:

buildPythonPackage rec {
  pname = "tqdm-multiprocess";
  version = "0.0.11";

  src = fetchPypi {
    inherit pname version;
    # nix-prefetch-url --unpack https://pypi.io/packages/source/t/tqdm-multiprocess/tqdm-multiprocess-0.0.11.tar.gz
    sha256 = "p0ACoSIuqcvozcm9RgEIxgCb41liH77puS0FFdTRgPc=";
  };
  
  # not included in PyPI version:
  preBuild = ''
    echo "twine" > requirements-dev.txt
  '';

  propagatedBuildInputs = [
    tqdm
    colorama
  ];

  nativeBuildInputs = [
    twine
  ];

  # If there are any tests to run, they would need the checkInputs attribute.
  # checkInputs = [ pytest ... ]; # Add any packages needed for running tests

  meta = with lib; {
    description = "Easy multiprocessing with tqdm and logging redirected to main process";
    homepage = "https://github.com/EleutherAI/tqdm-multiprocess";
    license = licenses.mit;
    maintainers = with maintainers; [ ];
  };
}
