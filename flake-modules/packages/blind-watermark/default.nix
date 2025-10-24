{
  fetchFromGitHub,
  buildPythonPackage,
  numpy,
  opencv-python,
  pywavelets,
  setuptools,
}:
buildPythonPackage rec {
  pname = "blind_watermark";
  version = "0.4.4";
  format = "pyproject";

  src = fetchFromGitHub {
    owner = "guofei9987";
    repo = "blind_watermark";
    rev = "935ce9906ceff2dfe2b1706cabec481b979be121";
    hash = "sha256-fp/TWBc4biYll84ZiUsJ3RImHp0NXahibJmE65nafk0=";
  };

  buildInputs = [ setuptools ];

  propagatedBuildInputs = [
    numpy
    opencv-python
    pywavelets
  ];
}
