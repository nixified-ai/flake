{
  ddt,
  docutils,
  fetchFromGitHub,
  buildPythonPackage,
  imageio,
  matplotlib,
  numpy,
  packaging,
}:
buildPythonPackage {
  version = "unstable-2025-04-16";
  pname = "color_matcher";
  src = fetchFromGitHub {
    owner = "hahnec";
    repo = "color-matcher";
    rev = "8c96eeb234f6a5e87d21aeb30d4790cf11c2682b";
    sha256 = "sha256-NN96tkfu65cJtlRqLeJpeMKiMdt5ze0kRVSpKaQT+bE=";
  };
  pyproject = false;
  nativeBuildInputs = [
    numpy
    imageio
    docutils
    ddt
    matplotlib
    packaging
  ];
}
