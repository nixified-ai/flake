{
  lib,
  buildPythonPackage,
  fetchPypi,
  setuptools,
}:

buildPythonPackage rec {
  pname = "comfyui_embedded_docs";
  version = "0.2.6";
  pyproject = true;

  src = fetchPypi {
    inherit pname version;
    hash = "sha256-ild/PuIWvo3NbAjpZYxvJX/7np6B9A8NNt6bSZJJdWo=";
  };

  build-system = [
    setuptools
  ];

  pythonImportsCheck = [
    "comfyui_embedded_docs"
  ];

  meta = {
    description = "Embedded documentation for ComfyUI nodes";
    homepage = "https://pypi.org/project/comfyui-embedded-docs/";
    license = lib.licenses.gpl3Only;
    maintainers = with lib.maintainers; [ ];
  };
}
