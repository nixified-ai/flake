{
  buildPythonPackage,
  fetchPypi,
  poetry-core,
  fire,
  numpy,
  opencv-python,
  pillow,
  torch,
  torchvision,
}:
buildPythonPackage rec {
  pname = "simple-lama-inpainting";
  version = "0.1.2";
  format = "pyproject";

  src = fetchPypi {
    inherit version;
    pname = "simple_lama_inpainting";
    hash = "sha256-V1y2FosRr1SJdvc3wApfMaTeUDvQxfFrpWQpQfmCZPw=";
  };

  buildInputs = [
    poetry-core
  ];

  postPatch = ''
    substituteInPlace pyproject.toml \
    --replace 'fire = "^0.5.0"' 'fire = "*"'

    substituteInPlace pyproject.toml \
    --replace 'numpy = "^1.24.3"' 'numpy = "*"'

    substituteInPlace pyproject.toml \
    --replace 'pillow = "^9.5.0"' 'pillow = "*"'
  '';

  propagatedBuildInputs = [
    fire
    numpy
    opencv-python
    pillow
    torch
    torchvision
  ];
}
